package com.javaweb.shop.service;

import com.javaweb.shop.dao.BrowseLogDao;
import com.javaweb.shop.dao.LoginLogDao;
import com.javaweb.shop.dao.OperationLogDao;
import com.javaweb.shop.dao.PurchaseLogDao;
import com.javaweb.shop.model.BrowseLog;
import com.javaweb.shop.model.LoginLog;
import com.javaweb.shop.model.OperationLog;
import com.javaweb.shop.model.OrderItem;
import com.javaweb.shop.model.PurchaseLog;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LogService {
    private final DataSource dataSource;
    private final LoginLogDao loginLogDao;
    private final BrowseLogDao browseLogDao;
    private final PurchaseLogDao purchaseLogDao;
    private final OperationLogDao operationLogDao;

    public LogService(DataSource dataSource) {
        this.dataSource = dataSource;
        this.loginLogDao = new LoginLogDao(dataSource);
        this.browseLogDao = new BrowseLogDao(dataSource);
        this.purchaseLogDao = new PurchaseLogDao(dataSource);
        this.operationLogDao = new OperationLogDao(dataSource);
    }

    // 记录用户登录日志（时间、IP、User-Agent）
    public void logLogin(long userId, String ipAddress, String userAgent) {
        try {
            LoginLog log = new LoginLog();
            log.setUserId(userId);
            log.setIpAddress(ipAddress);
            log.setUserAgent(userAgent);
            loginLogDao.insert(log);
        } catch (SQLException e) {
            // 日志写入失败不影响主流程
        }
    }

    // 记录用户浏览日志（商品ID、分类、停留时长）
    public void logBrowse(Long userId, long productId, Long categoryId, int dwellSeconds) {
        try {
            BrowseLog log = new BrowseLog();
            log.setUserId(userId);
            log.setProductId(productId);
            log.setCategoryId(categoryId);
            log.setDwellTimeSeconds(dwellSeconds);
            browseLogDao.insert(log);
        } catch (SQLException e) {
            // 日志写入失败不影响主流程
        }
    }

    // 记录用户购买日志（订单中每个商品的品类、单价、数量）
    public void logPurchase(long userId, long orderId, List<OrderItem> items) {
        try {
            Map<Long, Long> productCategoryMap = fetchProductCategories(items);
            List<PurchaseLog> logs = new ArrayList<>();
            for (OrderItem item : items) {
                PurchaseLog log = new PurchaseLog();
                log.setUserId(userId);
                log.setOrderId(orderId);
                log.setProductId(item.getProductId());
                log.setCategoryId(productCategoryMap.get(item.getProductId()));
                log.setUnitPrice(item.getUnitPrice());
                log.setQuantity(item.getQuantity());
                logs.add(log);
            }
            if (!logs.isEmpty()) {
                purchaseLogDao.batchInsert(logs);
            }
        } catch (SQLException e) {
            // 日志写入失败不影响主流程
        }
    }

    private Map<Long, Long> fetchProductCategories(List<OrderItem> items) throws SQLException {
        Map<Long, Long> map = new HashMap<>();
        if (items.isEmpty()) return map;
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }
        String sql = "SELECT id, category_id FROM products WHERE id IN (" + placeholders + ")";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (int i = 0; i < items.size(); i++) {
                stmt.setLong(i + 1, items.get(i).getProductId());
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    long cid = rs.getLong("category_id");
                    if (!rs.wasNull()) {
                        map.put(rs.getLong("id"), cid);
                    }
                }
            }
        }
        return map;
    }

    // 记录管理员/商家操作日志（操作时间、内容、IP、账号）
    public void logOperation(long operatorId, String role, String action, String detail, String ip) {
        try {
            OperationLog log = new OperationLog();
            log.setOperatorId(operatorId);
            log.setOperatorRole(role);
            log.setAction(action);
            log.setDetail(detail);
            log.setIpAddress(ip);
            operationLogDao.insert(log);
        } catch (SQLException e) {
            // 日志写入失败不影响主流程
        }
    }

    public LoginLogDao getLoginLogDao() { return loginLogDao; }
    public BrowseLogDao getBrowseLogDao() { return browseLogDao; }
    public PurchaseLogDao getPurchaseLogDao() { return purchaseLogDao; }
    public OperationLogDao getOperationLogDao() { return operationLogDao; }
}
