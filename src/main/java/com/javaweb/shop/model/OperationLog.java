package com.javaweb.shop.model;

import java.io.Serializable;
import java.time.LocalDateTime;

// 管理员/商家操作日志（时间、内容、IP、账号）
public class OperationLog implements Serializable {
    private static final long serialVersionUID = 1L;

    private long id;
    private long operatorId;
    private String operatorRole;
    private String action;
    private String detail;
    private String ipAddress;
    private LocalDateTime createdAt;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getOperatorId() { return operatorId; }
    public void setOperatorId(long operatorId) { this.operatorId = operatorId; }
    public String getOperatorRole() { return operatorRole; }
    public void setOperatorRole(String operatorRole) { this.operatorRole = operatorRole; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getDetail() { return detail; }
    public void setDetail(String detail) { this.detail = detail; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
