package com.example.demo.Controllers;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.DTO.CommentRequest;
import com.example.demo.DTO.CommentResponse;
import com.example.demo.DTO.RatingRequest;
import com.example.demo.DTO.ResourceDetailResponse;
import com.example.demo.Entities.Category;
import com.example.demo.Entities.Comment;
import com.example.demo.Entities.Favorite;
import com.example.demo.Entities.Rating;
import com.example.demo.Entities.User;
import com.example.demo.Repositories.CategoryRepository;
import com.example.demo.Repositories.CommentRepository;
import com.example.demo.Repositories.FavoriteRepository;
import com.example.demo.Repositories.RatingRepository;
import com.example.demo.Repositories.ResourceRepository;
import com.example.demo.Repositories.UserRepository;
import com.example.demo.Services.StorageService;

@RestController
@RequestMapping("/api/resources")
public class ResourceController {

    @Autowired
    private StorageService storageService;
    @Autowired
    private ResourceRepository resourceRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private RatingRepository ratingRepository;
    @Autowired
    private CategoryRepository categoryRepository;
    @Autowired
    private CommentRepository commentRepository;
    @Autowired
    private FavoriteRepository favoriteRepository;
    @Autowired
    private com.example.demo.Repositories.TagRepository tagRepository;

    // ENDPOINT 1: LIST ALL RESOURCES (Public)
    @GetMapping
    public List<com.example.demo.Entities.Resource> listResources() {
        return resourceRepository.findAll();
    }

    // ENDPOINT 2: UPLOAD A NEW RESOURCE (Requires Login)
    @PostMapping
    public ResponseEntity<?> uploadResource(
            @RequestParam("file") MultipartFile file,
            @RequestParam("title") String title,
            @RequestParam("description") String description,
            @RequestParam(value = "categories", required = false) List<String> categoryNames,
            @RequestParam(value = "tags", required = false) List<String> tagNames,
            @AuthenticationPrincipal OAuth2User oauthUser) {

        if (oauthUser == null) {
            return new ResponseEntity<>("You must be logged in.", HttpStatus.UNAUTHORIZED);
        }

        String email = oauthUser.getAttribute("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found in DB"));

        String filename = storageService.store(file);

        com.example.demo.Entities.Resource newResource = new com.example.demo.Entities.Resource();
        newResource.title = title;
        newResource.description = description;
        newResource.filePath = filename;
        newResource.uploaderId = user.id;
        newResource.viewCount = 0;
        newResource.downloadCount = 0;

        // Add categories if provided
        if (categoryNames != null && !categoryNames.isEmpty()) {
            for (String catName : categoryNames) {
                Category category = categoryRepository.findByName(catName)
                        .orElseGet(() -> {
                            Category newCat = new Category();
                            newCat.name = catName;
                            return categoryRepository.save(newCat);
                        });
                newResource.categories.add(category);
            }
        }

        // Add tags if provided (optional)
        if (tagNames != null && !tagNames.isEmpty()) {
            for (String tagName : tagNames) {
                com.example.demo.Entities.Tag tag = tagRepository.findByName(tagName)
                        .orElseGet(() -> {
                            // Create custom tag if it doesn't exist
                            com.example.demo.Entities.Tag newTag = new com.example.demo.Entities.Tag();
                            newTag.name = tagName;
                            newTag.isPredefined = false;
                            newTag.createdBy = user.id;
                            newTag.usageCount = 0;
                            return tagRepository.save(newTag);
                        });
                
                // Increment usage count
                tag.usageCount++;
                tagRepository.save(tag);
                
                newResource.tags.add(tag);
            }
        }

        resourceRepository.save(newResource);

        return ResponseEntity.ok().body("File uploaded successfully: " + filename);
    }

    // ENDPOINT 3: DOWNLOAD A FILE (Public)
    @GetMapping("/download/{filename:.+}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String filename) {
        Resource resource = storageService.loadAsResource(filename);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }

    // ENDPOINT 4: RATE A RESOURCE (Requires Login)
    // *** THIS IS THE SIMPLIFIED VERSION ***
    @PostMapping("/{id}/rate")
    public ResponseEntity<?> rateResource(
            @PathVariable Long id,
            @RequestBody RatingRequest ratingRequest,
            @AuthenticationPrincipal OAuth2User oauthUser) {

        if (oauthUser == null) {
            return new ResponseEntity<>("You must be logged in.", HttpStatus.UNAUTHORIZED);
        }

        String email = oauthUser.getAttribute("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found in DB"));
        Long userId = user.id;

        // 1. Check if resource exists
        resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));

        // 2. Check if user has already rated (using the UNIQUE constraint)
        if (ratingRepository.findByUserIdAndResourceId(userId, id).isPresent()) {
            return new ResponseEntity<>("You have already rated this resource.", HttpStatus.BAD_REQUEST);
        }

        // 3. Save the new rating.
        // We DO NOT calculate the average. The trigger does it!
        Rating newRating = new Rating();
        newRating.userId = userId;
        newRating.resourceId = id;
        newRating.ratingValue = ratingRequest.getRating();
        ratingRepository.save(newRating);

        // 4. Just return "OK". The frontend can re-fetch to see the new avg.
        return ResponseEntity.ok().body("Rating submitted.");
    }

    // ENDPOINT 5: GET DETAILED RESOURCE INFO
    @GetMapping("/{id}/details")
    public ResponseEntity<?> getResourceDetails(
            @PathVariable Long id,
            @AuthenticationPrincipal OAuth2User oauthUser) {

        com.example.demo.Entities.Resource resource = resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));

        // Increment view count
        resource.viewCount++;
        resourceRepository.save(resource);

        User uploader = userRepository.findById(resource.uploaderId).orElse(null);

        ResourceDetailResponse response = new ResourceDetailResponse();
        response.id = resource.id;
        response.title = resource.title;
        response.description = resource.description;
        response.filePath = resource.filePath;
        response.uploaderId = resource.uploaderId;
        response.uploaderName = uploader != null ? uploader.name : "Unknown";
        response.uploaderEmail = uploader != null ? uploader.email : "";
        response.averageRating = resource.averageRating;
        response.viewCount = resource.viewCount;
        response.downloadCount = resource.downloadCount;
        response.categories = resource.categories.stream()
                .map(cat -> cat.name)
                .collect(Collectors.toList());
        response.tags = resource.tags.stream()
                .map(tag -> tag.name)
                .collect(Collectors.toList());
        response.commentCount = resource.comments.size();
        response.favoriteCount = resource.favorites.size();
        response.createdAt = resource.createdAt;

        // Check if current user has favorited
        if (oauthUser != null) {
            String email = oauthUser.getAttribute("email");
            User user = userRepository.findByEmail(email).orElse(null);
            if (user != null) {
                response.isFavoritedByCurrentUser = 
                    favoriteRepository.existsByUserIdAndResourceId(user.id, id);
            }
        }

        return ResponseEntity.ok(response);
    }

    // ENDPOINT 6: ADD COMMENT (Requires Login)
    @PostMapping("/{id}/comments")
    public ResponseEntity<?> addComment(
            @PathVariable Long id,
            @RequestBody CommentRequest request,
            @AuthenticationPrincipal OAuth2User oauthUser) {

        if (oauthUser == null) {
            return new ResponseEntity<>("You must be logged in.", HttpStatus.UNAUTHORIZED);
        }

        com.example.demo.Entities.Resource resource = resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));

        String email = oauthUser.getAttribute("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found in DB"));

        Comment comment = new Comment();
        comment.content = request.content;
        comment.resource = resource;
        comment.user = user;
        commentRepository.save(comment);

        return ResponseEntity.ok("Comment added successfully");
    }

    // ENDPOINT 7: GET COMMENTS FOR RESOURCE
    @GetMapping("/{id}/comments")
    public ResponseEntity<?> getComments(@PathVariable Long id) {
        List<Comment> comments = commentRepository.findByResourceIdOrderByCreatedAtDesc(id);
        
        List<CommentResponse> response = comments.stream()
                .map(c -> new CommentResponse(
                    c.id,
                    c.content,
                    c.user.name,
                    c.user.email,
                    c.createdAt
                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    // ENDPOINT 8: TOGGLE FAVORITE (Requires Login)
    @PostMapping("/{id}/favorite")
    @Transactional
    public ResponseEntity<?> toggleFavorite(
            @PathVariable Long id,
            @AuthenticationPrincipal OAuth2User oauthUser) {

        if (oauthUser == null) {
            return new ResponseEntity<>("You must be logged in.", HttpStatus.UNAUTHORIZED);
        }

        com.example.demo.Entities.Resource resource = resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));

        String email = oauthUser.getAttribute("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found in DB"));

        if (favoriteRepository.existsByUserIdAndResourceId(user.id, id)) {
            favoriteRepository.deleteByUserIdAndResourceId(user.id, id);
            return ResponseEntity.ok().body("{\"favorited\": false, \"message\": \"Removed from favorites\"}");
        } else {
            Favorite favorite = new Favorite();
            favorite.user = user;
            favorite.resource = resource;
            favoriteRepository.save(favorite);
            return ResponseEntity.ok().body("{\"favorited\": true, \"message\": \"Added to favorites\"}");
        }
    }

    // ENDPOINT 9: GET USER'S FAVORITES (Requires Login)
    @GetMapping("/favorites")
    public ResponseEntity<?> getUserFavorites(@AuthenticationPrincipal OAuth2User oauthUser) {
        if (oauthUser == null) {
            return new ResponseEntity<>("You must be logged in.", HttpStatus.UNAUTHORIZED);
        }

        String email = oauthUser.getAttribute("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found in DB"));

        List<Favorite> favorites = favoriteRepository.findByUserId(user.id);
        List<com.example.demo.Entities.Resource> resources = favorites.stream()
                .map(f -> f.resource)
                .collect(Collectors.toList());

        return ResponseEntity.ok(resources);
    }

    // ENDPOINT 10: SEARCH RESOURCES
    @GetMapping("/search")
    public ResponseEntity<?> searchResources(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) List<String> tags) {

        List<com.example.demo.Entities.Resource> allResources = resourceRepository.findAll();

        // Filter by keyword in title or description
        if (keyword != null && !keyword.trim().isEmpty()) {
            String lowerKeyword = keyword.toLowerCase();
            allResources = allResources.stream()
                    .filter(r -> r.title.toLowerCase().contains(lowerKeyword) ||
                                (r.description != null && r.description.toLowerCase().contains(lowerKeyword)))
                    .collect(Collectors.toList());
        }

        // Filter by category
        if (category != null && !category.trim().isEmpty()) {
            allResources = allResources.stream()
                    .filter(r -> r.categories.stream().anyMatch(c -> c.name.equalsIgnoreCase(category)))
                    .collect(Collectors.toList());
        }

        // Filter by tags (resources must have at least one of the specified tags)
        if (tags != null && !tags.isEmpty()) {
            allResources = allResources.stream()
                    .filter(r -> r.tags.stream().anyMatch(t -> 
                        tags.stream().anyMatch(tagName -> t.name.equalsIgnoreCase(tagName))))
                    .collect(Collectors.toList());
        }

        return ResponseEntity.ok(allResources);
    }

    // ENDPOINT 11: GET ALL CATEGORIES
    @GetMapping("/categories")
    public ResponseEntity<?> getAllCategories() {
        return ResponseEntity.ok(categoryRepository.findAll());
    }

    // ENDPOINT 12: INCREMENT DOWNLOAD COUNT
    @PostMapping("/download/{id}/increment")
    public ResponseEntity<?> incrementDownloadCount(@PathVariable Long id) {
        com.example.demo.Entities.Resource resource = resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));
        
        resource.downloadCount++;
        resourceRepository.save(resource);

        return ResponseEntity.ok("Download count incremented");
    }

    // ENDPOINT 13: GET RECOMMENDED RESOURCES BASED ON TAGS
    @GetMapping("/{id}/recommendations")
    public ResponseEntity<?> getRecommendations(@PathVariable Long id, @RequestParam(defaultValue = "10") int limit) {
        com.example.demo.Entities.Resource currentResource = resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));

        // Get tags of current resource
        if (currentResource.tags.isEmpty()) {
            // If no tags, return popular resources
            return ResponseEntity.ok(
                resourceRepository.findAll().stream()
                    .filter(r -> !r.id.equals(id))
                    .sorted((r1, r2) -> {
                        int score1 = r1.downloadCount * 2 + r1.viewCount;
                        int score2 = r2.downloadCount * 2 + r2.viewCount;
                        return Integer.compare(score2, score1);
                    })
                    .limit(limit)
                    .collect(Collectors.toList())
            );
        }

        // Find resources with matching tags
        List<com.example.demo.Entities.Resource> allResources = resourceRepository.findAll();
        
        List<com.example.demo.Entities.Resource> recommendations = allResources.stream()
                .filter(r -> !r.id.equals(id)) // Exclude current resource
                .filter(r -> !r.tags.isEmpty()) // Only resources with tags
                .map(r -> {
                    // Calculate match score based on common tags
                    long commonTags = r.tags.stream()
                            .filter(tag -> currentResource.tags.stream()
                                    .anyMatch(ct -> ct.id.equals(tag.id)))
                            .count();
                    return new Object() {
                        final com.example.demo.Entities.Resource resource = r;
                        final long score = commonTags;
                    };
                })
                .filter(item -> item.score > 0) // Only resources with at least one common tag
                .sorted((a, b) -> {
                    // Sort by number of common tags (descending), then by rating
                    if (a.score != b.score) {
                        return Long.compare(b.score, a.score);
                    }
                    double ratingA = a.resource.averageRating == null ? 0.0 : a.resource.averageRating.doubleValue();
                    double ratingB = b.resource.averageRating == null ? 0.0 : b.resource.averageRating.doubleValue();
                    return Double.compare(ratingB, ratingA);
                })
                .limit(limit)
                .map(item -> item.resource)
                .collect(Collectors.toList());

        return ResponseEntity.ok(recommendations);
    }

    // ENDPOINT 14: GET RESOURCES BY TAG
    @GetMapping("/by-tag/{tagName}")
    public ResponseEntity<?> getResourcesByTag(@PathVariable String tagName) {
        List<com.example.demo.Entities.Resource> allResources = resourceRepository.findAll();
        
        List<com.example.demo.Entities.Resource> filtered = allResources.stream()
                .filter(r -> r.tags.stream().anyMatch(t -> t.name.equalsIgnoreCase(tagName)))
                .collect(Collectors.toList());

        return ResponseEntity.ok(filtered);
    }
}