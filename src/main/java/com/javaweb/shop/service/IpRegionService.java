package com.javaweb.shop.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

// IP 地址转地域（基于 ip-api.com 免费接口，结果带缓存）
public class IpRegionService {
    private static final String API_URL = "http://ip-api.com/json/";
    private final HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(3)).build();
    private final Map<String, String> cache = new ConcurrentHashMap<>();

    // 根据 IP 返回地域字符串，如"广东省深圳市"；失败返回 null
    public String getRegion(String ip) {
        if (ip == null || ip.isBlank() || "127.0.0.1".equals(ip) || "0:0:0:0:0:0:0:1".equals(ip)) {
            return "本地";
        }
        return cache.computeIfAbsent(ip, this::queryApi);
    }

    private String queryApi(String ip) {
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL + ip + "?fields=status,regionName,city&lang=zh-CN"))
                    .timeout(Duration.ofSeconds(3)).GET().build();
            HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() != 200) return null;
            String body = resp.body();
            if (!body.contains("\"success\"")) return null;
            String region = extractValue(body, "regionName");
            String city = extractValue(body, "city");
            if (region == null || region.isEmpty()) return null;
            return (city == null || city.isEmpty()) ? region : region + city;
        } catch (Exception e) {
            return null;
        }
    }

    private String extractValue(String json, String key) {
        String pattern = "\"" + key + "\":\"";
        int start = json.indexOf(pattern);
        if (start < 0) return "";
        start += pattern.length();
        int end = json.indexOf("\"", start);
        if (end < 0) return "";
        return json.substring(start, end);
    }
}
