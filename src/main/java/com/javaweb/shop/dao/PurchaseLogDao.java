package com.javaweb.shop.dao;

import com.javaweb.shop.model.PurchaseLog;

import javax.sql.DataSource;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PurchaseLogDao {
    private final DataSource dataSource;

    public PurchaseLogDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    // 批量插入购买日志（一笔订单含多个商品）
    public void batchInsert(List<PurchaseLog> logs) throws SQLException {
        String sql = "INSERT INTO user_purchase_logs (user_id, order_id, product_id, category_id, unit_price, quantity) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (PurchaseLog log : logs) {
                stmt.setLong(1, log.getUserId());
                stmt.setLong(2, log.getOrderId());
                stmt.setLong(3, log.getProductId());
                if (log.getCategoryId() != null) {
                    stmt.setLong(4, log.getCategoryId());
                } else {
                    stmt.setNull(4, Types.BIGINT);
                }
                stmt.setBigDecimal(5, log.getUnitPrice());
                stmt.setInt(6, log.getQuantity());
                stmt.addBatch();
            }
            stmt.executeBatch();
        }
    }

    public List<PurchaseLog> findByUserId(long userId, int limit) throws SQLException {
        String sql = "SELECT id, user_id, order_id, product_id, category_id, unit_price, quantity, purchased_at " +
                "FROM user_purchase_logs WHERE user_id = ? ORDER BY purchased_at DESC LIMIT ?";
        List<PurchaseLog> logs = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) logs.add(map(rs));
            }
        }
        return logs;
    }

    public List<PurchaseLog> findRecent(int limit) throws SQLException {
        String sql = "SELECT l.id, l.user_id, l.order_id, l.product_id, l.category_id, " +
                "l.unit_price, l.quantity, l.purchased_at, " +
                "u.username, p.name AS product_name, c.name AS category_name " +
                "FROM user_purchase_logs l " +
                "LEFT JOIN users u ON l.user_id = u.id " +
                "LEFT JOIN products p ON l.product_id = p.id " +
                "LEFT JOIN categories c ON l.category_id = c.id " +
                "ORDER BY l.purchased_at DESC LIMIT ?";
        List<PurchaseLog> logs = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) logs.add(map(rs));
            }
        }
        return logs;
    }

    public Map<Long, BigDecimal> categorySpendingByUser(long userId) throws SQLException {
        String sql = "SELECT category_id, SUM(unit_price * quantity) AS total FROM user_purchase_logs " +
                "WHERE user_id = ? AND category_id IS NOT NULL GROUP BY category_id";
        Map<Long, BigDecimal> result = new HashMap<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getLong("category_id"), rs.getBigDecimal("total"));
                }
            }
        }
        return result;
    }

    public Map<Long, Long> countByCategoryForUser(long userId) throws SQLException {
        String sql = "SELECT category_id, SUM(quantity) AS cnt FROM user_purchase_logs " +
                "WHERE user_id = ? AND category_id IS NOT NULL GROUP BY category_id";
        Map<Long, Long> result = new HashMap<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getLong("category_id"), rs.getLong("cnt"));
                }
            }
        }
        return result;
    }

    // 基于商品的协同过滤：找到购买了指定商品的其他用户还买了什么
    public List<long[]> findAlsoBoughtProductIds(long userId, List<Long> myProductIds, int limit) throws SQLException {
        if (myProductIds.isEmpty()) return new ArrayList<>();
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < myProductIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }
        String sql = "SELECT product_id, COUNT(*) AS cnt FROM user_purchase_logs " +
                "WHERE user_id != ? AND user_id IN (" +
                "  SELECT DISTINCT user_id FROM user_purchase_logs WHERE product_id IN (" + placeholders + ")" +
                ") AND product_id NOT IN (" + placeholders + ") " +
                "GROUP BY product_id ORDER BY cnt DESC LIMIT ?";
        List<long[]> result = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            int idx = 1;
            stmt.setLong(idx++, userId);
            for (Long pid : myProductIds) stmt.setLong(idx++, pid);
            for (Long pid : myProductIds) stmt.setLong(idx++, pid);
            stmt.setInt(idx, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    result.add(new long[]{rs.getLong("product_id"), rs.getLong("cnt")});
                }
            }
        }
        return result;
    }

    private PurchaseLog map(ResultSet rs) throws SQLException {
        PurchaseLog log = new PurchaseLog();
        log.setId(rs.getLong("id"));
        log.setUserId(rs.getLong("user_id"));
        log.setOrderId(rs.getLong("order_id"));
        log.setProductId(rs.getLong("product_id"));
        long cid = rs.getLong("category_id");
        log.setCategoryId(rs.wasNull() ? null : cid);
        setIfPresent(rs, "username", log::setUsername);
        setIfPresent(rs, "product_name", log::setProductName);
        setIfPresent(rs, "category_name", log::setCategoryName);
        log.setUnitPrice(rs.getBigDecimal("unit_price"));
        log.setQuantity(rs.getInt("quantity"));
        Timestamp ts = rs.getTimestamp("purchased_at");
        if (ts != null) log.setPurchasedAt(ts.toLocalDateTime());
        return log;
    }

    private void setIfPresent(ResultSet rs, String column, java.util.function.Consumer<String> setter)
            throws SQLException {
        try {
            setter.accept(rs.getString(column));
        } catch (SQLException ignored) {
            // Basic queries do not select display columns.
        }
    }
}
