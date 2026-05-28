package com.javaweb.shop.web;

import com.javaweb.shop.infra.db.DataSourceFactory;
import com.javaweb.shop.model.Product;
import com.javaweb.shop.model.User;
import com.javaweb.shop.service.OssService;
import com.javaweb.shop.service.RecommendationService;
import com.javaweb.shop.service.ValidationException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class RecommendationServlet extends HttpServlet {
    private RecommendationService recommendationService;

    @Override
    public void init() {
        this.recommendationService = new RecommendationService(DataSourceFactory.getDataSource());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        try {
            List<Product> products = recommendationService.getPersonalizedRecommendations(user.getId(), 12);
            signProductImages(products);
            request.setAttribute("products", products);
            request.getRequestDispatcher("/recommendations.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("加载推荐商品失败。", ex);
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        Object obj = request.getSession(false) != null
                ? request.getSession(false).getAttribute("currentUser") : null;
        return obj instanceof User ? (User) obj : null;
    }

    private void signProductImages(List<Product> products) {
        if (products == null || products.isEmpty()) return;
        OssService ossService = null;
        for (Product p : products) {
            if (p.getImageUrl() == null || p.getImageUrl().isBlank()) continue;
            try {
                if (ossService == null) ossService = new OssService();
                String signed = ossService.signUrl(p.getImageUrl());
                if (signed != null && !signed.isBlank()) p.setImageUrl(signed);
            } catch (ValidationException ex) { break; }
        }
    }
}
