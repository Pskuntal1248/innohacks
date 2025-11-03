package com.example.demo.Controllers;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.example.demo.DTO.RatingRequest;
import com.example.demo.Entities.Rating;
import com.example.demo.Entities.User;
import com.example.demo.Repositories.RatingRepository;
import com.example.demo.Repositories.ResourceRepository;
import com.example.demo.Repositories.UserRepository;
import com.example.demo.Services.StorageService;

/**
 * Test controller for frontend development - bypasses OAuth2 authentication
 * WARNING: Remove or disable this in production!
 */
@RestController
@RequestMapping("/api/test")
public class TestController {

    @Autowired
    private StorageService storageService;
    @Autowired
    private ResourceRepository resourceRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private RatingRepository ratingRepository;

    // ENDPOINT 1: LIST ALL RESOURCES (Public)
    @GetMapping("/resources")
    public ResponseEntity<?> listResources() {
        List<com.example.demo.Entities.Resource> resources = resourceRepository.findAll();
        return ResponseEntity.ok(resources);
    }

    // ENDPOINT 2: UPLOAD A NEW RESOURCE (Uses a test user)
    @PostMapping("/resources")
    public ResponseEntity<?> uploadResource(
            @RequestParam("file") MultipartFile file,
            @RequestParam("title") String title,
            @RequestParam("description") String description,
            @RequestParam(value = "userEmail", required = false, defaultValue = "test@example.com") String userEmail) {

        // Find or create a test user
        User user = userRepository.findByEmail(userEmail)
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.email = userEmail;
                    newUser.name = "Test User";
                    return userRepository.save(newUser);
                });

        String filename = storageService.store(file);

        com.example.demo.Entities.Resource newResource = new com.example.demo.Entities.Resource();
        newResource.title = title;
        newResource.description = description;
        newResource.filePath = filename;
        newResource.uploaderId = user.id;

        com.example.demo.Entities.Resource savedResource = resourceRepository.save(newResource);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "File uploaded successfully");
        response.put("filename", filename);
        response.put("resourceId", savedResource.id);
        response.put("resource", savedResource);

        return ResponseEntity.ok(response);
    }

    // ENDPOINT 3: DOWNLOAD A FILE (Public)
    @GetMapping("/resources/download/{filename:.+}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String filename) {
        Resource resource = storageService.loadAsResource(filename);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }

    // ENDPOINT 4: RATE A RESOURCE (Uses a test user)
    @PostMapping("/resources/{id}/rate")
    public ResponseEntity<?> rateResource(
            @PathVariable Long id,
            @RequestBody RatingRequest ratingRequest,
            @RequestParam(value = "userEmail", required = false, defaultValue = "test@example.com") String userEmail) {

        // Find or create a test user
        User user = userRepository.findByEmail(userEmail)
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.email = userEmail;
                    newUser.name = "Test User";
                    return userRepository.save(newUser);
                });

        Long userId = user.id;

        // 1. Check if resource exists
        com.example.demo.Entities.Resource resource = resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));

        // 2. Check if user has already rated
        if (ratingRepository.findByUserIdAndResourceId(userId, id).isPresent()) {
            return new ResponseEntity<>("You have already rated this resource.", HttpStatus.BAD_REQUEST);
        }

        // 3. Save the new rating
        Rating newRating = new Rating();
        newRating.userId = userId;
        newRating.resourceId = id;
        newRating.ratingValue = ratingRequest.getRating();
        ratingRepository.save(newRating);

        // 4. Return the updated resource
        com.example.demo.Entities.Resource updatedResource = resourceRepository.findById(id).get();
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Rating submitted successfully");
        response.put("resource", updatedResource);

        return ResponseEntity.ok(response);
    }

    // ENDPOINT 5: GET A SINGLE RESOURCE BY ID
    @GetMapping("/resources/{id}")
    public ResponseEntity<?> getResource(@PathVariable Long id) {
        com.example.demo.Entities.Resource resource = resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));
        return ResponseEntity.ok(resource);
    }

    // ENDPOINT 6: CREATE A TEST USER
    @PostMapping("/users")
    public ResponseEntity<?> createUser(
            @RequestParam("email") String email,
            @RequestParam("name") String name) {
        
        User existingUser = userRepository.findByEmail(email).orElse(null);
        if (existingUser != null) {
            return ResponseEntity.ok(existingUser);
        }

        User newUser = new User();
        newUser.email = email;
        newUser.name = name;
        User savedUser = userRepository.save(newUser);

        return ResponseEntity.ok(savedUser);
    }

    // ENDPOINT 7: LIST ALL USERS
    @GetMapping("/users")
    public ResponseEntity<?> listUsers() {
        List<User> users = userRepository.findAll();
        return ResponseEntity.ok(users);
    }

    // ENDPOINT 8: GET ALL RATINGS FOR A RESOURCE
    @GetMapping("/resources/{id}/ratings")
    public ResponseEntity<?> getResourceRatings(@PathVariable Long id) {
        // This would need a custom query - for now just return the resource with its average
        resourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resource not found"));
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "For detailed ratings, you would need to add a custom query");
        response.put("resourceId", id);
        return ResponseEntity.ok(response);
    }
}
