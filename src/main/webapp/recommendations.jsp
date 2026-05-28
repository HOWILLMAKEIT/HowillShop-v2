<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.javaweb.shop.model.Product" %>
<%@ page import="java.util.List" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>为你推荐</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<jsp:include page="/partials/navbar.jsp" />
<main>
    <div class="container">
        <h2>为你推荐</h2>
        <% if (products == null || products.isEmpty()) { %>
            <p>暂无推荐商品，请先浏览或购买一些商品。</p>
        <% } else { %>
        <div class="product-grid">
            <% for (Product p : products) {
                String imgSrc = "";
                if (p.getImageUrl() != null && !p.getImageUrl().isBlank()) {
                    imgSrc = p.getImageUrl().startsWith("http") ? p.getImageUrl() : contextPath + "/" + p.getImageUrl();
                }
            %>
            <a class="product-card" href="<%= contextPath %>/products/detail?productId=<%= p.getId() %>">
                <div class="product-thumb">
                    <% if (!imgSrc.isEmpty()) { %>
                        <img src="<%= imgSrc %>" alt="<%= p.getName() %>">
                    <% } %>
                </div>
                <div class="product-info">
                    <div class="product-name"><%= p.getName() %></div>
                    <div class="price">&yen;<%= p.getPrice() %></div>
                </div>
            </a>
            <% } %>
        </div>
        <% } %>
    </div>
</main>
</body>
</html>
