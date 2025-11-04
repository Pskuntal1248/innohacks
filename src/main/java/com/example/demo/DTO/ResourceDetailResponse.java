package com.example.demo.DTO;

import java.time.LocalDateTime;
import java.util.List;

public class ResourceDetailResponse {
    public Long id;
    public String title;
    public String description;
    public String filePath;
    public Long uploaderId;
    public String uploaderName;
    public String uploaderEmail;
    public Double averageRating;
    public Integer viewCount;
    public Integer downloadCount;
    public List<String> categories;
    public List<String> tags;
    public Integer commentCount;
    public Integer favoriteCount;
    public boolean isFavoritedByCurrentUser;
    public LocalDateTime createdAt;
}
