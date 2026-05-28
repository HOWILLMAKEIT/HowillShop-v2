package com.javaweb.shop.model;

import java.io.Serializable;
import java.time.LocalDateTime;

// 用户浏览日志（商品ID、分类、停留时长）
public class BrowseLog implements Serializable {
    private static final long serialVersionUID = 1L;

    private long id;
    private Long userId;
    private long productId;
    private Long categoryId;
    private String username;
    private String productName;
    private String categoryName;
    private int dwellTimeSeconds;
    private LocalDateTime browsedAt;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public long getProductId() { return productId; }
    public void setProductId(long productId) { this.productId = productId; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public int getDwellTimeSeconds() { return dwellTimeSeconds; }
    public void setDwellTimeSeconds(int dwellTimeSeconds) { this.dwellTimeSeconds = dwellTimeSeconds; }
    public LocalDateTime getBrowsedAt() { return browsedAt; }
    public void setBrowsedAt(LocalDateTime browsedAt) { this.browsedAt = browsedAt; }
}
