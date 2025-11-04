package com.example.demo.Entities;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "resources")
public class Resource {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(nullable = false)
    public String title;

    @Column(columnDefinition = "TEXT")
    public String description;

    @Column(name = "file_path", nullable = false)
    public String filePath;

    @Column(name = "uploader_id", nullable = false)
    public Long uploaderId;

    @Column(name = "average_rating", insertable = false, updatable = false)
    public Double averageRating; // Your DB trigger handles this

    @Column(name = "view_count")
    public Integer viewCount = 0;

    @Column(name = "download_count")
    public Integer downloadCount = 0;

    @ManyToMany
    @JoinTable(
        name = "resource_categories",
        joinColumns = @JoinColumn(name = "resource_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    public Set<Category> categories = new HashSet<>();

    @ManyToMany
    @JoinTable(
        name = "resource_tags",
        joinColumns = @JoinColumn(name = "resource_id"),
        inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    public Set<Tag> tags = new HashSet<>();

    @OneToMany(mappedBy = "resource", cascade = CascadeType.ALL)
    public Set<Comment> comments = new HashSet<>();

    @OneToMany(mappedBy = "resource", cascade = CascadeType.ALL)
    public Set<Favorite> favorites = new HashSet<>();

    @Column(name = "created_at", insertable = false, updatable = false)
    public LocalDateTime createdAt;
}