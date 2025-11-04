package com.example.demo.Repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.demo.Entities.Tag;

@Repository
public interface TagRepository extends JpaRepository<Tag, Long> {
    
    Optional<Tag> findByName(String name);
    
    List<Tag> findByIsPredefined(Boolean isPredefined);
    
    List<Tag> findByCreatedBy(Long userId);
    
    // Find tags by name containing keyword (case-insensitive)
    @Query("SELECT t FROM Tag t WHERE LOWER(t.name) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Tag> findByNameContaining(@Param("keyword") String keyword);
    
    // Get most popular tags
    @Query("SELECT t FROM Tag t ORDER BY t.usageCount DESC")
    List<Tag> findTopByUsageCount();
    
    // Check if tag name already exists (case-insensitive)
    @Query("SELECT CASE WHEN COUNT(t) > 0 THEN true ELSE false END FROM Tag t WHERE LOWER(t.name) = LOWER(:name)")
    Boolean existsByNameIgnoreCase(@Param("name") String name);
}
