package com.javaweb.shop.web;

import com.javaweb.shop.infra.db.DataSourceFactory;
import com.javaweb.shop.model.User;
import com.javaweb.shop.service.LogService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;

// 接收前端 JS 发送的浏览停留时长数据
public class BrowseLogServlet extends HttpServlet {
    private LogService logService;

    @Override
    public void init() {
        this.logService = new LogService(DataSourceFactory.getDataSource());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        Long userId = null;
        Object currentUser = request.getSession(false) != null
                ? request.getSession(false).getAttribute("currentUser") : null;
        if (currentUser instanceof User) {
            userId = ((User) currentUser).getId();
        }

        try {
            BufferedReader reader = request.getReader();
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String body = sb.toString();
            long productId = extractLong(body, "productId");
            long categoryId = extractLong(body, "categoryId");
            int dwellTime = (int) extractLong(body, "dwellTime");

            logService.logBrowse(userId, productId, categoryId > 0 ? categoryId : null, dwellTime);
            response.setStatus(200);
            response.getWriter().write("{\"ok\":true}");
        } catch (Exception e) {
            response.setStatus(400);
            response.getWriter().write("{\"ok\":false}");
        }
    }

    private long extractLong(String json, String key) {
        String pattern = "\"" + key + "\":";
        int start = json.indexOf(pattern);
        if (start < 0) return 0;
        start += pattern.length();
        int end = start;
        while (end < json.length() && Character.isDigit(json.charAt(end))) {
            end++;
        }
        if (end == start) return 0;
        return Long.parseLong(json.substring(start, end));
    }
}
