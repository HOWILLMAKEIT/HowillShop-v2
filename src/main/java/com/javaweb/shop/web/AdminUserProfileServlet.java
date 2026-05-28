package com.javaweb.shop.web;

import com.javaweb.shop.infra.db.DataSourceFactory;
import com.javaweb.shop.model.User;
import com.javaweb.shop.model.UserProfile;
import com.javaweb.shop.service.AnalyticsService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class AdminUserProfileServlet extends HttpServlet {
    private AnalyticsService analyticsService;

    @Override
    public void init() {
        this.analyticsService = new AnalyticsService(DataSourceFactory.getDataSource());
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
            List<UserProfile> profiles = analyticsService.getUserProfiles(50);
            request.setAttribute("profiles", profiles);
            request.getRequestDispatcher("/admin_profiles.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("加载用户画像失败。", ex);
        }
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
}
