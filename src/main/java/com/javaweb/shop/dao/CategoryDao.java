package com.javaweb.shop.dao;

import com.javaweb.shop.model.Category;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

// 分类数据访问
public class CategoryDao {
    private final DataSource dataSource;

    public CategoryDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public List<Category> listActiveCategories() throws SQLException {
        String sql = "SELECT id, name FROM categories WHERE status = 1 ORDER BY sort_order, id";
        List<Category> categories = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Category category = new Category();
                category.setId(rs.getLong("id"));
                category.setName(rs.getString("name"));
                categories.add(category);
            }
        }
        return categories;
    }

    public List<Category> listAllCategories() throws SQLException {
        String sql = "SELECT id, name, status, sort_order FROM categories ORDER BY sort_order, id";
        List<Category> categories = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Category category = new Category();
                category.setId(rs.getLong("id"));
                category.setName(rs.getString("name"));
                category.setStatus(rs.getInt("status"));
                category.setSortOrder(rs.getInt("sort_order"));
                categories.add(category);
            }
        }
        return categories;
    }

    public Optional<String> findNameById(long id) throws SQLException {
        String sql = "SELECT name FROM categories WHERE id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.ofNullable(rs.getString("name"));
                }
            }
        }
        return Optional.empty();
    }

    public void insertCategory(String name, int sortOrder) throws SQLException {
        String sql = "INSERT INTO categories (name, sort_order, status) VALUES (?, ?, 1)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name.trim());
            stmt.setInt(2, sortOrder);
            stmt.executeUpdate();
        }
    }

    public boolean deleteCategory(long id) throws SQLException {
        String sql = "DELETE FROM categories WHERE id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean toggleStatus(long id) throws SQLException {
        String sql = "UPDATE categories SET status = IF(status = 1, 0, 1) WHERE id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        }
    }
}
