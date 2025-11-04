package com.example.demo.DTO;

public class TagResponse {
    public Long id;
    public String name;
    public String description;
    public Boolean isPredefined;
    public Integer usageCount;
    
    public TagResponse() {}
    
    public TagResponse(Long id, String name, String description, Boolean isPredefined, Integer usageCount) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.isPredefined = isPredefined;
        this.usageCount = usageCount;
    }
}
