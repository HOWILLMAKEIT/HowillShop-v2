package com.javaweb.shop.dao;

import com.javaweb.shop.model.OperationLog;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OperationLogDao {
    private final DataSource dataSource;

    public OperationLogDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public long insert(OperationLog log) throws SQLException {
        String sql = "INSERT INTO operation_logs (operator_id, operator_role, action, detail, ip_address) " +
                "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setLong(1, log.getOperatorId());
            stmt.setString(2, log.getOperatorRole());
            stmt.setString(3, log.getAction());
            stmt.setString(4, log.getDetail());
            stmt.setString(5, log.getIpAddress());
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        throw new SQLException("插入操作日志失败");
    }

    public List<OperationLog> findRecent(int limit) throws SQLException {
        String sql = "SELECT id, operator_id, operator_role, action, detail, ip_address, created_at " +
                "FROM operation_logs ORDER BY created_at DESC LIMIT ?";
        List<OperationLog> logs = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) logs.add(map(rs));
            }
        }
        return logs;
    }

    public List<OperationLog> findByOperatorId(long operatorId, int limit) throws SQLException {
        String sql = "SELECT id, operator_id, operator_role, action, detail, ip_address, created_at " +
                "FROM operation_logs WHERE operator_id = ? ORDER BY created_at DESC LIMIT ?";
        List<OperationLog> logs = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, operatorId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) logs.add(map(rs));
            }
        }
        return logs;
    }

    private OperationLog map(ResultSet rs) throws SQLException {
        OperationLog log = new OperationLog();
        log.setId(rs.getLong("id"));
        log.setOperatorId(rs.getLong("operator_id"));
        log.setOperatorRole(rs.getString("operator_role"));
        log.setAction(rs.getString("action"));
        log.setDetail(rs.getString("detail"));
        log.setIpAddress(rs.getString("ip_address"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) log.setCreatedAt(ts.toLocalDateTime());
        return log;
    }
}
