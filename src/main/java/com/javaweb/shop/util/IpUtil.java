package com.javaweb.shop.util;

import javax.servlet.http.HttpServletRequest;

public final class IpUtil {
    private IpUtil() {
    }

    public static String getRealIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isBlank()) {
            return ip.split(",")[0].trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (ip != null && !ip.isBlank()) {
            return ip.trim();
        }
        return request.getRemoteAddr();
    }
}
