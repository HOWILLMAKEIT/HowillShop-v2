package com.javaweb.shop.service;

import com.javaweb.shop.dao.CategoryDao;
import com.javaweb.shop.dao.BrowseLogDao;
import com.javaweb.shop.dao.LoginLogDao;
import com.javaweb.shop.dao.OperationLogDao;
import com.javaweb.shop.dao.OrderDao;
import com.javaweb.shop.dao.PurchaseLogDao;
import com.javaweb.shop.dao.UserDao;
import com.javaweb.shop.model.CategorySales;
import com.javaweb.shop.model.BrowseLog;
import com.javaweb.shop.model.LoginLog;
import com.javaweb.shop.model.OperationLog;
import com.javaweb.shop.model.ProductSales;
import com.javaweb.shop.model.PurchaseLog;
import com.javaweb.shop.model.SalesSummary;
import com.javaweb.shop.model.User;
import com.javaweb.shop.model.UserProfile;

import javax.sql.DataSource;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// 数据分析服务（销售趋势、品类分布、用户画像、异常检测）
public class AnalyticsService {
    private final OrderDao orderDao;
    private final CategoryDao categoryDao;
    private final BrowseLogDao browseLogDao;
    private final UserDao userDao;
    private final PurchaseLogDao purchaseLogDao;
    private final LoginLogDao loginLogDao;
    private final OperationLogDao operationLogDao;
    private final IpRegionService ipRegionService = new IpRegionService();

    public AnalyticsService(DataSource dataSource) {
        this.orderDao = new OrderDao(dataSource);
        this.categoryDao = new CategoryDao(dataSource);
        this.browseLogDao = new BrowseLogDao(dataSource);
        this.userDao = new UserDao(dataSource);
        this.purchaseLogDao = new PurchaseLogDao(dataSource);
        this.loginLogDao = new LoginLogDao(dataSource);
        this.operationLogDao = new OperationLogDao(dataSource);
    }

    // 按日汇总销售趋势（趋势图用）
    public List<SalesSummary> getSalesTrend(LocalDate start, LocalDate end) throws SQLException {
        return orderDao.listDailySales(start, end);
    }

    // 商品销售排行榜（Top N）
    public List<ProductSales> getProductSalesRanking(LocalDate start, LocalDate end) throws SQLException {
        return orderDao.listProductSales(start, end);
    }

    // 品类销售分布（饼图用）
    public List<CategorySales> getCategorySales(LocalDate start, LocalDate end) throws SQLException {
        return orderDao.listCategorySales(start, end);
    }

    // 生成用户画像（地域、购买力、偏好品类）
    public List<UserProfile> getUserProfiles(int limit) throws SQLException {
        List<User> customers = userDao.findByRole("CUSTOMER");
        List<UserProfile> profiles = new ArrayList<>();
        int count = 0;
        for (User u : customers) {
            if (count >= limit) break;
            UserProfile p = new UserProfile();
            p.setUserId(u.getId());
            p.setUsername(u.getUsername());
            p.setLastLoginAt(u.getLastLoginAt());

            // 地域：从最近登录 IP 推断
            List<LoginLog> recentLogs = loginLogDao.findByUserId(u.getId(), 1);
            if (!recentLogs.isEmpty() && recentLogs.get(0).getIpAddress() != null) {
                String region = ipRegionService.getRegion(recentLogs.get(0).getIpAddress());
                p.setRegion(region != null ? region : "未知");
            } else {
                p.setRegion("未知");
            }

            BigDecimal totalSpent = orderDao.totalSpentByUser(u.getId());
            List<com.javaweb.shop.model.PurchaseLog> logs = purchaseLogDao.findByUserId(u.getId(), 100);
            p.setTotalOrders(logs.size());
            if (!logs.isEmpty()) {
                p.setAvgOrderAmount(totalSpent.divide(BigDecimal.valueOf(logs.size()), 2, RoundingMode.HALF_UP));
            } else {
                p.setAvgOrderAmount(BigDecimal.ZERO);
            }

            // 偏好品类
            Map<Long, Long> catCount = purchaseLogDao.countByCategoryForUser(u.getId());
            if (!catCount.isEmpty()) {
                long topCatId = catCount.entrySet().stream()
                        .max(Map.Entry.comparingByValue()).get().getKey();
                p.setTopCategoryName(categoryDao.findNameById(topCatId).orElse("品类#" + topCatId));
            } else {
                p.setTopCategoryName("-");
            }

            profiles.add(p);
            count++;
        }
        return profiles;
    }

    public Map<String, Object> getDashboardStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", userDao.countByRole("CUSTOMER"));
        stats.put("totalMerchants", userDao.countByRole("MERCHANT"));
        stats.put("totalOrders", orderDao.countAll());
        stats.put("totalRevenue", orderDao.totalRevenue());
        return stats;
    }

    // 按小时检测销售异常（超过均值 3 倍标红）
    public List<SalesSummary> detectAnomalies(LocalDate date) throws SQLException {
        return orderDao.listHourlySales(date);
    }

    public List<LoginLog> getRecentLoginLogs(int limit) throws SQLException {
        return loginLogDao.findRecent(limit);
    }

    public List<OperationLog> getRecentOperationLogs(int limit) throws SQLException {
        return operationLogDao.findRecent(limit);
    }

    public List<BrowseLog> getRecentBrowseLogs(int limit) throws SQLException {
        return browseLogDao.findRecent(limit);
    }

    public List<PurchaseLog> getRecentPurchaseLogs(int limit) throws SQLException {
        return purchaseLogDao.findRecent(limit);
    }
}
