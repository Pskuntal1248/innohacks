package com.example.demo.Repositories;

import com.example.demo.Entities.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface RatingRepository extends JpaRepository<Rating, Long> {

    // Checks if a user has already rated a resource
    Optional<Rating> findByUserIdAndResourceId(Long userId, Long resourceId);
}