package com.javaweb.shop.service;

import com.javaweb.shop.dao.UserDao;
import com.javaweb.shop.model.User;
import com.javaweb.shop.util.PasswordHasher;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public class AdminService {
    private final UserDao userDao;

    public AdminService(UserDao userDao) {
        this.userDao = userDao;
    }

    public List<User> listMerchants() throws SQLException {
        return userDao.findByRole("MERCHANT");
    }

    public List<User> listAllUsers() throws SQLException {
        return userDao.listAll();
    }

    public long createMerchant(String username, String email, String phone, String rawPassword)
            throws SQLException, ValidationException {
        if (isBlank(username) || isBlank(email) || isBlank(rawPassword)) {
            throw new ValidationException("商家用户名、邮箱和密码不能为空。");
        }
        if (rawPassword.length() < 6) {
            throw new ValidationException("密码长度不能少于6位。");
        }
        String normalizedUsername = username.trim();
        String normalizedEmail = email.trim();
        if (userDao.findByUsername(normalizedUsername).isPresent()) {
            throw new ValidationException("用户名已被占用。");
        }
        if (userDao.findByEmail(normalizedEmail).isPresent()) {
            throw new ValidationException("邮箱已被注册。");
        }
        User user = new User();
        user.setUsername(normalizedUsername);
        user.setEmail(normalizedEmail);
        user.setPhone(phone == null ? null : phone.trim());
        user.setRole("MERCHANT");
        user.setStatus(1);
        return userDao.insert(user, PasswordHasher.hash(rawPassword));
    }

    public void resetPassword(long userId) throws SQLException, ValidationException {
        Optional<User> user = userDao.findById(userId);
        if (user.isEmpty()) throw new ValidationException("用户不存在。");
        String defaultHash = PasswordHasher.hash("123456");
        userDao.updatePassword(userId, defaultHash);
    }

    public void resetPassword(long userId, String newPassword) throws SQLException, ValidationException {
        Optional<User> user = userDao.findById(userId);
        if (user.isEmpty()) throw new ValidationException("用户不存在。");
        if (newPassword == null || newPassword.length() < 6) {
            throw new ValidationException("密码长度不能少于6位。");
        }
        userDao.updatePassword(userId, PasswordHasher.hash(newPassword));
    }

    public void toggleStatus(long userId) throws SQLException, ValidationException {
        Optional<User> user = userDao.findById(userId);
        if (user.isEmpty()) throw new ValidationException("用户不存在。");
        userDao.updateStatus(userId, user.get().getStatus() == 1 ? 0 : 1);
    }

    public void deleteMerchant(long userId) throws SQLException, ValidationException {
        Optional<User> user = userDao.findById(userId);
        if (user.isEmpty()) throw new ValidationException("用户不存在。");
        if (!"MERCHANT".equalsIgnoreCase(user.get().getRole())) {
            throw new ValidationException("只能删除销售人员账号。");
        }
        int deleted = userDao.deleteById(userId);
        if (deleted == 0) {
            throw new ValidationException("销售人员账号删除失败。");
        }
    }

    public long countCustomers() throws SQLException {
        return userDao.countByRole("CUSTOMER");
    }

    public long countMerchants() throws SQLException {
        return userDao.countByRole("MERCHANT");
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
