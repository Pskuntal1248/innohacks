package com.example.demo.Entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "ratings")
public class Rating {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(name = "rating_value", nullable = false)
    public Integer ratingValue;

    @Column(name = "user_id", nullable = false)
    public Long userId;

    @Column(name = "resource_id", nullable = false)
    public Long resourceId;

    @Column(name = "created_at", insertable = false, updatable = false)
    public LocalDateTime createdAt;
}