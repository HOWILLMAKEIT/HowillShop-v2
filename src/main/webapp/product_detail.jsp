<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.javaweb.shop.model.Product" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>商品详情</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<jsp:include page="/partials/navbar.jsp" />
<%
    Product product = (Product) request.getAttribute("product");
    String contextPath = request.getContextPath();
%>
<main>
    <div class="container">
        <div class="card">
            <% if (product == null) { %>
                <p>商品不存在。</p>
            <% } else { %>
                <div class="product-detail">
                    <div class="product-media">
                        <%
                            String imageUrl = product.getImageUrl();
                            String imageSrc = null;
                            if (imageUrl != null && !imageUrl.isBlank()) {
                                if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://") || imageUrl.startsWith("/")) {
                                    imageSrc = imageUrl;
                                } else {
                                    imageSrc = contextPath + "/" + imageUrl;
                                }
                            }
                        %>
                        <% if (imageSrc != null) { %>
                            <img src="<%= imageSrc %>" alt="<%= product.getName() %>">
                        <% } else { %>
                            <img src="" alt="暂无图片">
                        <% } %>
                    </div>
                    <div>
                        <h1><%= product.getName() %></h1>
                        <div class="muted">分类：<%= product.getCategoryName() == null ? "-" : product.getCategoryName() %></div>
                        <div class="muted">商家：<%= product.getMerchantName() == null ? "平台自营" : product.getMerchantName() %></div>
                        <div class="price">￥<%= product.getPrice() %></div>
                        <div class="muted">库存：<%= product.getStock() %></div>
                        <p><%= product.getDescription() == null ? "" : product.getDescription() %></p>
                        <form method="post" action="${pageContext.request.contextPath}/cart/add">
                            <input type="hidden" name="productId" value="<%= product.getId() %>">
                            <div class="form-group">
                                <label for="quantity">数量</label>
                                <input id="quantity" type="number" name="quantity" min="1" value="1">
                            </div>
                            <div class="actions">
                                <button type="submit">加入购物车</button>
                                <a class="btn secondary" href="${pageContext.request.contextPath}/products">返回列表</a>
                            </div>
                        </form>
                    </div>
                </div>
            <% } %>
        </div>
        <%-- "浏览过此商品的人也买了" 推荐区域 --%>
        <% List<Product> relatedProducts = (List<Product>) request.getAttribute("relatedProducts");
           if (relatedProducts != null && !relatedProducts.isEmpty()) { %>
        <div class="card" style="margin-top:1.5rem">
            <h2>浏览过此商品的人也买了</h2>
            <div class="product-grid">
                <% for (Product rp : relatedProducts) {
                    String rpImg = rp.getImageUrl();
                    String rpSrc = null;
                    if (rpImg != null && !rpImg.isBlank()) {
                        if (rpImg.startsWith("http://") || rpImg.startsWith("https://") || rpImg.startsWith("/")) {
                            rpSrc = rpImg;
                        } else {
                            rpSrc = contextPath + "/" + rpImg;
                        }
                    }
                %>
                <a class="product-card" href="<%= contextPath %>/products/detail?productId=<%= rp.getId() %>">
                    <img src="<%= rpSrc != null ? rpSrc : "" %>" alt="<%= rp.getName() %>">
                    <div class="product-card-body">
                        <div class="product-card-title"><%= rp.getName() %></div>
                        <div class="price">￥<%= rp.getPrice() %></div>
                    </div>
                </a>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
</main>
<script>
    (function() {
        var startTime = Date.now();
        var productId = <%= product != null ? product.getId() : 0 %>;
        var categoryId = <%= product != null ? product.getCategoryId() : 0 %>;
        window.addEventListener('beforeunload', function() {
            var dwellSeconds = Math.round((Date.now() - startTime) / 1000);
            if (dwellSeconds > 0) {
                navigator.sendBeacon('${pageContext.request.contextPath}/api/browse',
                    JSON.stringify({productId: productId, categoryId: categoryId, dwellTime: dwellSeconds}));
            }
        });
    })();
</script>
</body>
</html>
