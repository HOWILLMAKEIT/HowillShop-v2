package com.javaweb.shop.web;

import com.javaweb.shop.infra.db.DataSourceFactory;
import com.javaweb.shop.model.ProductSales;
import com.javaweb.shop.model.SalesSummary;
import com.javaweb.shop.model.User;
import com.javaweb.shop.service.AnalyticsService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

// 管理员 — 仪表盘首页（KPI 卡片、销售趋势、商品排行）
public class AdminDashboardServlet extends HttpServlet {
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
            Map<String, Object> stats = analyticsService.getDashboardStats();
            request.setAttribute("totalUsers", stats.get("totalUsers"));
            request.setAttribute("totalMerchants", stats.get("totalMerchants"));
            request.setAttribute("totalOrders", stats.get("totalOrders"));
            request.setAttribute("totalRevenue", stats.get("totalRevenue"));

            LocalDate end = LocalDate.now();
            LocalDate start = end.minusDays(29);
            List<SalesSummary> trend = analyticsService.getSalesTrend(start, end);
            List<ProductSales> ranking = analyticsService.getProductSalesRanking(start, end);
            request.setAttribute("trend", trend);
            request.setAttribute("ranking", ranking);

            request.getRequestDispatcher("/admin_dashboard.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("加载仪表盘数据失败。", ex);
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
