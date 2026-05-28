package com.javaweb.shop.model;

import java.io.Serializable;

// 商品库存区间统计
public class StockDistribution implements Serializable {
    private static final long serialVersionUID = 1L;

    private String stockRange;
    private long productCount;

    public String getStockRange() {
        return stockRange;
    }

    public void setStockRange(String stockRange) {
        this.stockRange = stockRange;
    }

    public long getProductCount() {
        return productCount;
    }

    public void setProductCount(long productCount) {
        this.productCount = productCount;
    }
}
