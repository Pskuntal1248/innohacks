package com.example.demo.Entities;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "tags")
public class Tag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(unique = true, nullable = false, length = 50)
    public String name;

    @Column(columnDefinition = "TEXT")
    public String description;

    @Column(name = "is_predefined")
    public Boolean isPredefined = false; // true for system tags, false for custom tags

    @Column(name = "created_by")
    public Long createdBy; // user ID who created this tag (null for predefined tags) 

    @Column(name = "usage_count")
    public Integer usageCount = 0; // track how many times this tag is used

    @ManyToMany(mappedBy = "tags")
    public Set<Resource> resources = new HashSet<>();

    @Column(name = "created_at", insertable = false, updatable = false)
    public LocalDateTime createdAt;



    // Constructor
    public Tag() {}

    public Tag(String name, String description, Boolean isPredefined) {
        this.name = name;
        this.description = description;
        this.isPredefined = isPredefined;
    }
}
