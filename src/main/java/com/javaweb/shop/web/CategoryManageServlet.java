package com.javaweb.shop.web;

import com.javaweb.shop.dao.CategoryDao;
import com.javaweb.shop.infra.db.DataSourceFactory;
import com.javaweb.shop.model.Category;
import com.javaweb.shop.model.User;
import com.javaweb.shop.service.LogService;
import com.javaweb.shop.util.IpUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

// 品类管理入口（商家 & 管理员）
public class CategoryManageServlet extends HttpServlet {
    private CategoryDao categoryDao;
    private LogService logService;

    @Override
    public void init() {
        this.categoryDao = new CategoryDao(DataSourceFactory.getDataSource());
        this.logService = new LogService(DataSourceFactory.getDataSource());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getAuthorizedUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        try {
            List<Category> categories = categoryDao.listAllCategories();
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/admin_categories.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("加载分类数据失败。", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getAuthorizedUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                String name = request.getParameter("name");
                int sortOrder = parseIntOrDefault(request.getParameter("sortOrder"), 0);
                if (name == null || name.trim().isEmpty()) {
                    request.getSession().setAttribute("categoryError", "分类名称不能为空。");
                } else {
                    categoryDao.insertCategory(name, sortOrder);
                    logService.logOperation(user.getId(), user.getRole(), "ADD_CATEGORY", "添加分类: " + name, IpUtil.getRealIp(request));
                    request.getSession().setAttribute("categoryMessage", "分类已添加。");
                }
            } else if ("delete".equals(action)) {
                long id = parseLong(request.getParameter("categoryId"));
                boolean deleted = categoryDao.deleteCategory(id);
                if (deleted) {
                    logService.logOperation(user.getId(), user.getRole(), "DELETE_CATEGORY", "删除分类ID: " + id, IpUtil.getRealIp(request));
                    request.getSession().setAttribute("categoryMessage", "分类已删除。");
                } else {
                    request.getSession().setAttribute("categoryError", "删除失败，该分类下可能仍有商品。");
                }
            } else if ("toggle".equals(action)) {
                long id = parseLong(request.getParameter("categoryId"));
                categoryDao.toggleStatus(id);
                logService.logOperation(user.getId(), user.getRole(), "TOGGLE_CATEGORY", "切换分类状态ID: " + id, IpUtil.getRealIp(request));
                request.getSession().setAttribute("categoryMessage", "分类状态已更新。");
            }
        } catch (SQLException ex) {
            if (ex.getMessage() != null && ex.getMessage().contains("foreign key")) {
                request.getSession().setAttribute("categoryError", "删除失败，该分类下仍有商品。");
            } else {
                request.getSession().setAttribute("categoryError", "操作失败：" + ex.getMessage());
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }

    private User getAuthorizedUser(HttpServletRequest request) {
        Object obj = request.getSession(false) != null
                ? request.getSession(false).getAttribute("currentUser") : null;
        if (obj instanceof User) {
            User user = (User) obj;
            if ("MERCHANT".equalsIgnoreCase(user.getRole()) || "ADMIN".equalsIgnoreCase(user.getRole())) {
                return user;
            }
        }
        return null;
    }

    private long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) return 0;
        try { return Long.parseLong(value.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) return defaultValue;
        try { return Integer.parseInt(value.trim()); }
        catch (NumberFormatException e) { return defaultValue; }
    }
}
