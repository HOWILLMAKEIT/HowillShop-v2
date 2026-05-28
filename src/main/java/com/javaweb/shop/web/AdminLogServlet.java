package com.javaweb.shop.web;

import com.javaweb.shop.infra.db.DataSourceFactory;
import com.javaweb.shop.model.BrowseLog;
import com.javaweb.shop.model.LoginLog;
import com.javaweb.shop.model.OperationLog;
import com.javaweb.shop.model.PurchaseLog;
import com.javaweb.shop.model.User;
import com.javaweb.shop.service.AnalyticsService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class AdminLogServlet extends HttpServlet {
    private AnalyticsService analyticsService;

    @Override
    public void init() {
        this.analyticsService = new AnalyticsService(DataSourceFactory.getDataSource());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User admin = getAuthorizedUser(request);
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        try {
            List<LoginLog> loginLogs = analyticsService.getRecentLoginLogs(100);
            List<OperationLog> opLogs = analyticsService.getRecentOperationLogs(100);
            List<BrowseLog> browseLogs = analyticsService.getRecentBrowseLogs(100);
            List<PurchaseLog> purchaseLogs = analyticsService.getRecentPurchaseLogs(100);
            request.setAttribute("loginLogs", loginLogs);
            request.setAttribute("opLogs", opLogs);
            request.setAttribute("browseLogs", browseLogs);
            request.setAttribute("purchaseLogs", purchaseLogs);
            request.getRequestDispatcher("/admin_logs.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("加载日志失败。", ex);
        }
    }

    private User getAuthorizedUser(HttpServletRequest request) {
        Object obj = request.getSession(false) != null
                ? request.getSession(false).getAttribute("currentUser") : null;
        if (obj instanceof User) {
            User user = (User) obj;
            String role = user.getRole();
            if ("ADMIN".equalsIgnoreCase(role) || "MERCHANT".equalsIgnoreCase(role)) return user;
        }
        return null;
    }
}
