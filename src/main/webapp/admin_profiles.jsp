<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.javaweb.shop.model.UserProfile" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>用户画像</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<jsp:include page="/partials/navbar.jsp" />
<%
    List<UserProfile> profiles = (List<UserProfile>) request.getAttribute("profiles");
%>
<main>
    <div class="container">
        <h2>用户画像</h2>
        <table>
            <thead>
                <tr>
                    <th>用户ID</th>
                    <th>用户名</th>
                    <th>地域</th>
                    <th>偏好品类</th>
                    <th>平均消费</th>
                    <th>订单数</th>
                    <th>最近登录</th>
                </tr>
            </thead>
            <tbody>
                <% if (profiles != null) for (UserProfile p : profiles) { %>
                <tr>
                    <td><%= p.getUserId() %></td>
                    <td><%= p.getUsername() %></td>
                    <td><%= p.getRegion() != null ? p.getRegion() : "未知" %></td>
                    <td><%= p.getTopCategoryName() %></td>
                    <td>&yen;<%= p.getAvgOrderAmount() %></td>
                    <td><%= p.getTotalOrders() %></td>
                    <td><%= p.getLastLoginAt() != null ? p.getLastLoginAt() : "-" %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</main>
</body>
</html>
