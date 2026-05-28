package com.javaweb.shop.web;

import com.javaweb.shop.dao.OrderDao;
import com.javaweb.shop.infra.db.DataSourceFactory;
import com.javaweb.shop.model.CategorySales;
import com.javaweb.shop.model.SalesSummary;
import com.javaweb.shop.model.StockDistribution;
import com.javaweb.shop.model.User;
import com.javaweb.shop.service.AnalyticsService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

// 管理员 — 数据分析（趋势图、品类饼图、异常检测、订单状态分布）
public class AdminAnalyticsServlet extends HttpServlet {
    private AnalyticsService analyticsService;
    private OrderDao orderDao;

    @Override
    public void init() {
        this.analyticsService = new AnalyticsService(DataSourceFactory.getDataSource());
        this.orderDao = new OrderDao(DataSourceFactory.getDataSource());
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
            LocalDate end = LocalDate.now().plusDays(1);
            LocalDate start = end.minusDays(30);

            String range = request.getParameter("range");
            if ("week".equals(range)) start = end.minusDays(7);
            else if ("month".equals(range)) start = end.minusDays(30);
            else if ("quarter".equals(range)) start = end.minusDays(90);

            List<SalesSummary> trend = analyticsService.getSalesTrend(start, end.minusDays(1));
            List<CategorySales> categorySales = analyticsService.getCategorySales(start, end);
            List<SalesSummary> hourly = analyticsService.detectAnomalies(LocalDate.now());
            List<SalesSummary> statusStats = orderDao.listOrderStatusStats();
            List<StockDistribution> stockStats = orderDao.listStockDistribution();

            // 前后半段环比增长率
            String growthRate = calcGrowthRate(trend);

            // 移动平均预测：最近 7 天均值外推未来 3 天
            List<String> forecastDates = new ArrayList<>();
            List<BigDecimal> forecastAmounts = new ArrayList<>();
            calcForecast(trend, forecastDates, forecastAmounts);

            request.setAttribute("trend", trend);
            request.setAttribute("growthRate", growthRate);
            request.setAttribute("forecastDates", forecastDates);
            request.setAttribute("forecastAmounts", forecastAmounts);
            request.setAttribute("categorySales", categorySales);
            request.setAttribute("hourly", hourly);
            request.setAttribute("statusStats", statusStats);
            request.setAttribute("stockStats", stockStats);
            request.setAttribute("range", range != null ? range : "month");
            request.getRequestDispatcher("/admin_analytics.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("加载分析数据失败。", ex);
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

    private String calcGrowthRate(List<SalesSummary> trend) {
        if (trend == null || trend.size() < 2) return "数据不足";
        int mid = trend.size() / 2;
        BigDecimal firstHalf = BigDecimal.ZERO;
        BigDecimal secondHalf = BigDecimal.ZERO;
        for (int i = 0; i < mid; i++) firstHalf = firstHalf.add(trend.get(i).getTotalAmount());
        for (int i = mid; i < trend.size(); i++) secondHalf = secondHalf.add(trend.get(i).getTotalAmount());
        if (firstHalf.compareTo(BigDecimal.ZERO) == 0) return secondHalf.compareTo(BigDecimal.ZERO) > 0 ? "+100%" : "持平";
        BigDecimal rate = secondHalf.subtract(firstHalf).multiply(BigDecimal.valueOf(100)).divide(firstHalf, 1, RoundingMode.HALF_UP);
        return (rate.compareTo(BigDecimal.ZERO) >= 0 ? "+" : "") + rate + "%";
    }

    private void calcForecast(List<SalesSummary> trend, List<String> dates, List<BigDecimal> amounts) {
        if (trend == null || trend.size() < 7) return;
        // 取最近 7 天的均值作为预测值
        BigDecimal sum = BigDecimal.ZERO;
        int window = Math.min(7, trend.size());
        for (int i = trend.size() - window; i < trend.size(); i++) {
            sum = sum.add(trend.get(i).getTotalAmount());
        }
        BigDecimal avg = sum.divide(BigDecimal.valueOf(window), 2, RoundingMode.HALF_UP);
        if (avg.compareTo(BigDecimal.ZERO) == 0) return;
        // 预测未来 3 天
        LocalDate lastDate = trend.get(trend.size() - 1).getSaleDate();
        for (int i = 1; i <= 3; i++) {
            dates.add(lastDate.plusDays(i).toString());
            amounts.add(avg);
        }
    }
}
