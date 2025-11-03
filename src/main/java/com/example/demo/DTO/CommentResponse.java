package com.example.demo.DTO;

import java.time.LocalDateTime;

public class CommentResponse {
    public Long id;
    public String content;
    public String userName;
    public String userEmail;
    public LocalDateTime createdAt;

    public CommentResponse(Long id, String content, String userName, String userEmail, LocalDateTime createdAt) {
        this.id = id;
        this.content = content;
        this.userName = userName;
        this.userEmail = userEmail;
        this.createdAt = createdAt;
    }
}
