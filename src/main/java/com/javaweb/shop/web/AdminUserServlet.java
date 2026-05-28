package com.javaweb.shop.web;

import com.javaweb.shop.dao.UserDao;
import com.javaweb.shop.infra.db.DataSourceFactory;
import com.javaweb.shop.model.User;
import com.javaweb.shop.service.AdminService;
import com.javaweb.shop.service.LogService;
import com.javaweb.shop.service.ValidationException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

// 管理员 — 用户管理
public class AdminUserServlet extends HttpServlet {
    private AdminService adminService;
    private LogService logService;

    @Override
    public void init() {
        UserDao userDao = new UserDao(DataSourceFactory.getDataSource());
        this.adminService = new AdminService(userDao);
        this.logService = new LogService(DataSourceFactory.getDataSource());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User admin = getAdminUser(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        try {
            List<User> users = adminService.listAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/admin_users.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("加载用户列表失败。", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User admin = getAdminUser(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String action = request.getParameter("action");
        long userId = parseLong(request.getParameter("userId"));
        try {
            if ("createMerchant".equals(action)) {
                long merchantId = adminService.createMerchant(
                        request.getParameter("username"),
                        request.getParameter("email"),
                        request.getParameter("phone"),
                        request.getParameter("password"));
                logService.logOperation(admin.getId(), admin.getRole(), "CREATE_MERCHANT",
                        "创建销售人员ID=" + merchantId, request.getRemoteAddr());
            } else if ("resetPassword".equals(action)) {
                adminService.resetPassword(userId);
                logService.logOperation(admin.getId(), admin.getRole(), "RESET_PASSWORD",
                        "重置用户ID=" + userId + "的密码", request.getRemoteAddr());
            } else if ("toggleStatus".equals(action)) {
                adminService.toggleStatus(userId);
                logService.logOperation(admin.getId(), admin.getRole(), "TOGGLE_STATUS",
                        "切换用户ID=" + userId + "的状态", request.getRemoteAddr());
            } else if ("deleteMerchant".equals(action)) {
                adminService.deleteMerchant(userId);
                logService.logOperation(admin.getId(), admin.getRole(), "DELETE_MERCHANT",
                        "删除销售人员ID=" + userId, request.getRemoteAddr());
            }
        } catch (ValidationException ex) {
            request.getSession().setAttribute("userManageError", ex.getMessage());
        } catch (SQLException ex) {
            throw new ServletException("操作失败。", ex);
        }
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private User getAdminUser(HttpServletRequest request) {
        Object obj = request.getSession(false) != null
                ? request.getSession(false).getAttribute("currentUser") : null;
        if (obj instanceof User) {
            User user = (User) obj;
            if ("ADMIN".equalsIgnoreCase(user.getRole())) return user;
        }
        return null;
    }

    private long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) return 0;
        try { return Long.parseLong(value.trim()); }
        catch (NumberFormatException e) { return 0; }
    }
}
