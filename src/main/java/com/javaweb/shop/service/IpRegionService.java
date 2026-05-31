package com.javaweb.shop.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

// IP 地址转地域（基于百度 IP 定位接口，对国内 IP 定位准确）
public class IpRegionService {
    private static final String API_URL = "https://opendata.baidu.com/api.php?resource_id=6006&oe=utf8&query=";
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
                    .uri(URI.create(API_URL + ip))
                    .timeout(Duration.ofSeconds(3)).GET().build();
            HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() != 200) return null;
            String body = resp.body();
            // 提取 location 字段，格式如："广东省深圳市 电信"
            String location = extractValue(body, "location");
            if (location == null || location.isEmpty()) return null;
            // 去掉运营商后缀（空格后面的部分）
            int spaceIdx = location.indexOf(' ');
            return spaceIdx > 0 ? location.substring(0, spaceIdx) : location;
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
