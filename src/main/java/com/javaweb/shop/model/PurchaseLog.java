package com.javaweb.shop.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

// 用户购买日志（商品、分类、单价、数量）
public class PurchaseLog implements Serializable {
    private static final long serialVersionUID = 1L;

    private long id;
    private long userId;
    private long orderId;
    private long productId;
    private Long categoryId;
    private String username;
    private String productName;
    private String categoryName;
    private BigDecimal unitPrice;
    private int quantity;
    private LocalDateTime purchasedAt;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getUserId() { return userId; }
    public void setUserId(long userId) { this.userId = userId; }
    public long getOrderId() { return orderId; }
    public void setOrderId(long orderId) { this.orderId = orderId; }
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
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public LocalDateTime getPurchasedAt() { return purchasedAt; }
    public void setPurchasedAt(LocalDateTime purchasedAt) { this.purchasedAt = purchasedAt; }
}
