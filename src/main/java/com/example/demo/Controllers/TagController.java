package com.example.demo.Controllers;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.DTO.TagRequest;
import com.example.demo.DTO.TagResponse;
import com.example.demo.Entities.Tag;
import com.example.demo.Entities.User;
import com.example.demo.Repositories.TagRepository;
import com.example.demo.Repositories.UserRepository;

@RestController
@RequestMapping("/api/tags")
public class TagController {

    @Autowired
    private TagRepository tagRepository;

    @Autowired
    private UserRepository userRepository;

    // ENDPOINT 1: GET ALL TAGS (Public)
    @GetMapping
    public ResponseEntity<?> getAllTags() {
        List<Tag> tags = tagRepository.findAll();
        List<TagResponse> response = tags.stream()
                .map(t -> new TagResponse(t.id, t.name, t.description, t.isPredefined, t.usageCount))
                .collect(Collectors.toList());
        return ResponseEntity.ok(response);
    }

    // ENDPOINT 2: GET PREDEFINED TAGS (Public)
    @GetMapping("/predefined")
    public ResponseEntity<?> getPredefinedTags() {
        List<Tag> tags = tagRepository.findByIsPredefined(true);
        List<TagResponse> response = tags.stream()
                .map(t -> new TagResponse(t.id, t.name, t.description, t.isPredefined, t.usageCount))
                .collect(Collectors.toList());
        return ResponseEntity.ok(response);
    }

    // ENDPOINT 3: GET POPULAR TAGS (Public)
    @GetMapping("/popular")
    public ResponseEntity<?> getPopularTags(@RequestParam(defaultValue = "20") int limit) {
        List<Tag> tags = tagRepository.findTopByUsageCount();
        List<TagResponse> response = tags.stream()
                .limit(limit)
                .map(t -> new TagResponse(t.id, t.name, t.description, t.isPredefined, t.usageCount))
                .collect(Collectors.toList());
        return ResponseEntity.ok(response);
    }

    // ENDPOINT 4: SEARCH TAGS BY KEYWORD (Public)
    @GetMapping("/search")
    public ResponseEntity<?> searchTags(@RequestParam String keyword) {
        List<Tag> tags = tagRepository.findByNameContaining(keyword);
        List<TagResponse> response = tags.stream()
                .map(t -> new TagResponse(t.id, t.name, t.description, t.isPredefined, t.usageCount))
                .collect(Collectors.toList());
        return ResponseEntity.ok(response);
    }

    // ENDPOINT 5: CREATE CUSTOM TAG (Requires Login - Teachers/Uploaders)
    @PostMapping
    public ResponseEntity<?> createCustomTag(
            @RequestBody TagRequest request,
            @AuthenticationPrincipal OAuth2User oauthUser) {

        if (oauthUser == null) {
            return new ResponseEntity<>("You must be logged in to create tags.", HttpStatus.UNAUTHORIZED);
        }

        // Validate tag name
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            return new ResponseEntity<>("Tag name cannot be empty.", HttpStatus.BAD_REQUEST);
        }

        String tagName = request.getName().trim();

        // Check if tag already exists (case-insensitive)
        if (tagRepository.existsByNameIgnoreCase(tagName)) {
            return new ResponseEntity<>("Tag already exists.", HttpStatus.CONFLICT);
        }

        String email = oauthUser.getAttribute("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found in DB"));

        Tag newTag = new Tag();
        newTag.name = tagName;
        newTag.description = request.getDescription();
        newTag.isPredefined = false;
        newTag.createdBy = user.id;
        newTag.usageCount = 0;

        Tag savedTag = tagRepository.save(newTag);

        TagResponse response = new TagResponse(
            savedTag.id,
            savedTag.name,
            savedTag.description,
            savedTag.isPredefined,
            savedTag.usageCount
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // ENDPOINT 6: GET TAGS CREATED BY USER (Requires Login)
    @GetMapping("/my-tags")
    public ResponseEntity<?> getMyTags(@AuthenticationPrincipal OAuth2User oauthUser) {
        if (oauthUser == null) {
            return new ResponseEntity<>("You must be logged in.", HttpStatus.UNAUTHORIZED);
        }

        String email = oauthUser.getAttribute("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found in DB"));

        List<Tag> tags = tagRepository.findByCreatedBy(user.id);
        List<TagResponse> response = tags.stream()
                .map(t -> new TagResponse(t.id, t.name, t.description, t.isPredefined, t.usageCount))
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    // ENDPOINT 7: DELETE CUSTOM TAG (Requires Login - Only creator can delete)
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTag(
            @PathVariable Long id,
            @AuthenticationPrincipal OAuth2User oauthUser) {

        if (oauthUser == null) {
            return new ResponseEntity<>("You must be logged in.", HttpStatus.UNAUTHORIZED);
        }

        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tag not found"));

        // Cannot delete predefined tags
        if (tag.isPredefined) {
            return new ResponseEntity<>("Cannot delete predefined tags.", HttpStatus.FORBIDDEN);
        }

        String email = oauthUser.getAttribute("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found in DB"));

        // Only the creator can delete the tag
        if (!tag.createdBy.equals(user.id)) {
            return new ResponseEntity<>("You can only delete tags you created.", HttpStatus.FORBIDDEN);
        }

        tagRepository.delete(tag);
        return ResponseEntity.ok("Tag deleted successfully");
    }

    // ENDPOINT 8: GET TAG DETAILS
    @GetMapping("/{id}")
    public ResponseEntity<?> getTagDetails(@PathVariable Long id) {
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tag not found"));

        TagResponse response = new TagResponse(
            tag.id,
            tag.name,
            tag.description,
            tag.isPredefined,
            tag.usageCount
        );

        return ResponseEntity.ok(response);
    }
}
