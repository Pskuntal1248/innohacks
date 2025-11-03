package com.example.demo.Repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.Entities.Comment;

public interface CommentRepository extends JpaRepository<Comment, Long> {
    List<Comment> findByResourceIdOrderByCreatedAtDesc(Long resourceId);
}
