package com.javaweb.shop.service;

import com.javaweb.shop.dao.BrowseLogDao;
import com.javaweb.shop.dao.ProductDao;
import com.javaweb.shop.dao.PurchaseLogDao;
import com.javaweb.shop.model.Product;
import com.javaweb.shop.model.PurchaseLog;

import javax.sql.DataSource;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class RecommendationService {
    private final BrowseLogDao browseLogDao;
    private final PurchaseLogDao purchaseLogDao;
    private final ProductDao productDao;

    public RecommendationService(DataSource dataSource) {
        this.browseLogDao = new BrowseLogDao(dataSource);
        this.purchaseLogDao = new PurchaseLogDao(dataSource);
        this.productDao = new ProductDao(dataSource);
    }

    // "浏览过此商品的人也买了" — 基于共同浏览行为的推荐
    public List<Product> getRelatedProducts(long productId, int limit) throws SQLException {
        List<long[]> coBrowsed = browseLogDao.findCoBrowsedProductIds(productId, limit * 3);
        List<Product> result = new ArrayList<>();
        Set<Long> seen = new HashSet<>();
        for (long[] pair : coBrowsed) {
            long relatedId = pair[0];
            if (seen.contains(relatedId) || relatedId == productId) continue;
            try {
                Product p = productDao.findById(relatedId).orElse(null);
                if (p != null) {
                    result.add(p);
                    seen.add(relatedId);
                    if (result.size() >= limit) break;
                }
            } catch (SQLException ignored) {}
        }
        return result;
    }

    // 个性化推荐 — 基于购买历史的协同过滤（基于物品）
    // 核心思路：找到"购买了和我相同商品的用户"还买了什么，按频次排序推荐
    public List<Product> getPersonalizedRecommendations(long userId, int limit) throws SQLException {
        List<PurchaseLog> myPurchases = purchaseLogDao.findByUserId(userId, 100);
        if (myPurchases.isEmpty()) return new ArrayList<>();

        Set<Long> myProducts = new HashSet<>();
        List<Long> myProductIds = new ArrayList<>();
        for (PurchaseLog p : myPurchases) {
            if (myProducts.add(p.getProductId())) {
                myProductIds.add(p.getProductId());
            }
        }

        // 协同过滤：购买过相同商品的用户还买了什么
        List<long[]> alsoBought = purchaseLogDao.findAlsoBoughtProductIds(userId, myProductIds, limit * 3);
        List<Product> result = new ArrayList<>();
        Set<Long> seen = new HashSet<>(myProducts);
        for (long[] pair : alsoBought) {
            long relatedId = pair[0];
            if (seen.contains(relatedId)) continue;
            try {
                Product p = productDao.findById(relatedId).orElse(null);
                if (p != null) {
                    result.add(p);
                    seen.add(relatedId);
                    if (result.size() >= limit) break;
                }
            } catch (SQLException ignored) {}
        }

        // 协同过滤结果不足时，用热门商品补充
        if (result.size() < limit) {
            try {
                List<Product> all = productDao.listProducts(null, null, 0, limit * 2);
                for (Product p : all) {
                    if (!seen.contains(p.getId())) {
                        result.add(p);
                        seen.add(p.getId());
                        if (result.size() >= limit) break;
                    }
                }
            } catch (SQLException ignored) {}
        }
        return result;
    }
}
