package com.javaweb.shop.model;

import java.io.Serializable;
import java.time.LocalDateTime;

// 用户登录日志（时间、IP、User-Agent）
public class LoginLog implements Serializable {
    private static final long serialVersionUID = 1L;

    private long id;
    private long userId;
    private String ipAddress;
    private String userAgent;
    private LocalDateTime loginAt;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getUserId() { return userId; }
    public void setUserId(long userId) { this.userId = userId; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
    public LocalDateTime getLoginAt() { return loginAt; }
    public void setLoginAt(LocalDateTime loginAt) { this.loginAt = loginAt; }
}
