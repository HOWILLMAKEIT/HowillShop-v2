<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.javaweb.shop.model.LoginLog" %>
<%@ page import="com.javaweb.shop.model.OperationLog" %>
<%@ page import="com.javaweb.shop.model.BrowseLog" %>
<%@ page import="com.javaweb.shop.model.PurchaseLog" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>系统日志</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<jsp:include page="/partials/navbar.jsp" />
<%
    List<LoginLog> loginLogs = (List<LoginLog>) request.getAttribute("loginLogs");
    List<OperationLog> opLogs = (List<OperationLog>) request.getAttribute("opLogs");
    List<BrowseLog> browseLogs = (List<BrowseLog>) request.getAttribute("browseLogs");
    List<PurchaseLog> purchaseLogs = (List<PurchaseLog>) request.getAttribute("purchaseLogs");
%>
<main>
    <div class="container">
        <h2>系统日志</h2>

        <h3>登录日志</h3>
        <table>
            <thead>
                <tr><th>ID</th><th>用户ID</th><th>IP地址</th><th>时间</th></tr>
            </thead>
            <tbody>
                <% if (loginLogs != null) for (LoginLog l : loginLogs) { %>
                <tr>
                    <td><%= l.getId() %></td>
                    <td><%= l.getUserId() %></td>
                    <td><%= l.getIpAddress() != null ? l.getIpAddress() : "-" %></td>
                    <td><%= l.getLoginAt() %></td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <h3>操作日志</h3>
        <table>
            <thead>
                <tr><th>ID</th><th>操作者ID</th><th>角色</th><th>动作</th><th>详情</th><th>IP</th><th>时间</th></tr>
            </thead>
            <tbody>
                <% if (opLogs != null) for (OperationLog l : opLogs) { %>
                <tr>
                    <td><%= l.getId() %></td>
                    <td><%= l.getOperatorId() %></td>
                    <td><%= l.getOperatorRole() %></td>
                    <td><%= l.getAction() %></td>
                    <td><%= l.getDetail() != null ? l.getDetail() : "-" %></td>
                    <td><%= l.getIpAddress() != null ? l.getIpAddress() : "-" %></td>
                    <td><%= l.getCreatedAt() %></td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <h3>浏览日志</h3>
        <table>
            <thead>
                <tr><th>ID</th><th>用户</th><th>商品</th><th>分类</th><th>停留时长(秒)</th><th>时间</th></tr>
            </thead>
            <tbody>
                <% if (browseLogs != null) for (BrowseLog l : browseLogs) { %>
                <tr>
                    <td><%= l.getId() %></td>
                    <td><%= l.getUsername() != null ? l.getUsername() : (l.getUserId() != null ? "用户ID=" + l.getUserId() : "未登录用户") %></td>
                    <td><%= l.getProductName() != null ? l.getProductName() : "商品ID=" + l.getProductId() %></td>
                    <td><%= l.getCategoryName() != null ? l.getCategoryName() : (l.getCategoryId() != null ? "分类ID=" + l.getCategoryId() : "-") %></td>
                    <td><%= l.getDwellTimeSeconds() %></td>
                    <td><%= l.getBrowsedAt() %></td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <h3>购买日志</h3>
        <table>
            <thead>
                <tr><th>ID</th><th>用户</th><th>订单ID</th><th>商品</th><th>分类</th><th>单价</th><th>数量</th><th>时间</th></tr>
            </thead>
            <tbody>
                <% if (purchaseLogs != null) for (PurchaseLog l : purchaseLogs) { %>
                <tr>
                    <td><%= l.getId() %></td>
                    <td><%= l.getUsername() != null ? l.getUsername() : "用户ID=" + l.getUserId() %></td>
                    <td><%= l.getOrderId() %></td>
                    <td><%= l.getProductName() != null ? l.getProductName() : "商品ID=" + l.getProductId() %></td>
                    <td><%= l.getCategoryName() != null ? l.getCategoryName() : (l.getCategoryId() != null ? "分类ID=" + l.getCategoryId() : "-") %></td>
                    <td><%= l.getUnitPrice() %></td>
                    <td><%= l.getQuantity() %></td>
                    <td><%= l.getPurchasedAt() %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</main>
</body>
</html>
