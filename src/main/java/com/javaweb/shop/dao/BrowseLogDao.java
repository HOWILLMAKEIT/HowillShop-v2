package com.javaweb.shop.dao;

import com.javaweb.shop.model.BrowseLog;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BrowseLogDao {
    private final DataSource dataSource;

    public BrowseLogDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    // 插入浏览日志（含停留时长），返回自增ID
    public long insert(BrowseLog log) throws SQLException {
        String sql = "INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds) " +
                "VALUES (?, ?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (log.getUserId() != null) {
                stmt.setLong(1, log.getUserId());
            } else {
                stmt.setNull(1, Types.BIGINT);
            }
            stmt.setLong(2, log.getProductId());
            if (log.getCategoryId() != null) {
                stmt.setLong(3, log.getCategoryId());
            } else {
                stmt.setNull(3, Types.BIGINT);
            }
            stmt.setInt(4, log.getDwellTimeSeconds());
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        throw new SQLException("插入浏览日志失败");
    }

    public List<BrowseLog> findByUserId(long userId, int limit) throws SQLException {
        String sql = "SELECT id, user_id, product_id, category_id, dwell_time_seconds, browsed_at " +
                "FROM user_browse_logs WHERE user_id = ? ORDER BY browsed_at DESC LIMIT ?";
        List<BrowseLog> logs = new ArrayList<>();
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

    public List<BrowseLog> findRecent(int limit) throws SQLException {
        String sql = "SELECT b.id, b.user_id, b.product_id, b.category_id, b.dwell_time_seconds, b.browsed_at, " +
                "u.username, p.name AS product_name, c.name AS category_name " +
                "FROM user_browse_logs b " +
                "LEFT JOIN users u ON b.user_id = u.id " +
                "LEFT JOIN products p ON b.product_id = p.id " +
                "LEFT JOIN categories c ON b.category_id = c.id " +
                "ORDER BY b.browsed_at DESC LIMIT ?";
        List<BrowseLog> logs = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) logs.add(map(rs));
            }
        }
        return logs;
    }

    // "浏览过的人也买了"：查找与指定商品被同一用户浏览过的其他商品
    public List<long[]> findCoBrowsedProductIds(long productId, int limit) throws SQLException {
        String sql = "SELECT b2.product_id, COUNT(*) AS cnt FROM user_browse_logs b1 " +
                "JOIN user_browse_logs b2 ON b1.user_id = b2.user_id AND b1.product_id != b2.product_id " +
                "WHERE b1.product_id = ? AND b1.user_id IS NOT NULL " +
                "GROUP BY b2.product_id ORDER BY cnt DESC LIMIT ?";
        List<long[]> result = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, productId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    result.add(new long[]{rs.getLong(1), rs.getLong(2)});
                }
            }
        }
        return result;
    }

    private BrowseLog map(ResultSet rs) throws SQLException {
        BrowseLog log = new BrowseLog();
        log.setId(rs.getLong("id"));
        long uid = rs.getLong("user_id");
        log.setUserId(rs.wasNull() ? null : uid);
        log.setProductId(rs.getLong("product_id"));
        long cid = rs.getLong("category_id");
        log.setCategoryId(rs.wasNull() ? null : cid);
        setIfPresent(rs, "username", log::setUsername);
        setIfPresent(rs, "product_name", log::setProductName);
        setIfPresent(rs, "category_name", log::setCategoryName);
        log.setDwellTimeSeconds(rs.getInt("dwell_time_seconds"));
        Timestamp ts = rs.getTimestamp("browsed_at");
        if (ts != null) log.setBrowsedAt(ts.toLocalDateTime());
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
