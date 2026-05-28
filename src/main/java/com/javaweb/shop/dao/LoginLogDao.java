package com.javaweb.shop.dao;

import com.javaweb.shop.model.LoginLog;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LoginLogDao {
    private final DataSource dataSource;

    public LoginLogDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    // 插入登录日志，返回自增ID
    public long insert(LoginLog log) throws SQLException {
        String sql = "INSERT INTO user_login_logs (user_id, ip_address, user_agent) VALUES (?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setLong(1, log.getUserId());
            stmt.setString(2, log.getIpAddress());
            stmt.setString(3, log.getUserAgent());
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        throw new SQLException("插入登录日志失败");
    }

    public List<LoginLog> findByUserId(long userId, int limit) throws SQLException {
        String sql = "SELECT id, user_id, ip_address, user_agent, login_at FROM user_login_logs " +
                "WHERE user_id = ? ORDER BY login_at DESC LIMIT ?";
        List<LoginLog> logs = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(map(rs));
                }
            }
        }
        return logs;
    }

    public List<LoginLog> findRecent(int limit) throws SQLException {
        String sql = "SELECT id, user_id, ip_address, user_agent, login_at FROM user_login_logs " +
                "ORDER BY login_at DESC LIMIT ?";
        List<LoginLog> logs = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    logs.add(map(rs));
                }
            }
        }
        return logs;
    }

    private LoginLog map(ResultSet rs) throws SQLException {
        LoginLog log = new LoginLog();
        log.setId(rs.getLong("id"));
        log.setUserId(rs.getLong("user_id"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setUserAgent(rs.getString("user_agent"));
        Timestamp ts = rs.getTimestamp("login_at");
        if (ts != null) log.setLoginAt(ts.toLocalDateTime());
        return log;
    }
}
