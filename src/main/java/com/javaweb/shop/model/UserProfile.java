package com.javaweb.shop.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class UserProfile {
    private long userId;
    private String username;
    private String region;
    private String topCategoryName;
    private BigDecimal avgOrderAmount;
    private long totalOrders;
    private LocalDateTime lastLoginAt;

    public long getUserId() { return userId; }
    public void setUserId(long userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }
    public String getTopCategoryName() { return topCategoryName; }
    public void setTopCategoryName(String topCategoryName) { this.topCategoryName = topCategoryName; }
    public BigDecimal getAvgOrderAmount() { return avgOrderAmount; }
    public void setAvgOrderAmount(BigDecimal avgOrderAmount) { this.avgOrderAmount = avgOrderAmount; }
    public long getTotalOrders() { return totalOrders; }
    public void setTotalOrders(long totalOrders) { this.totalOrders = totalOrders; }
    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
}
