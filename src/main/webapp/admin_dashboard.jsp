<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.javaweb.shop.model.SalesSummary" %>
<%@ page import="com.javaweb.shop.model.ProductSales" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>管理后台</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
</head>
<body>
<jsp:include page="/partials/navbar.jsp" />
<%
    Object totalUsers = request.getAttribute("totalUsers");
    Object totalMerchants = request.getAttribute("totalMerchants");
    Object totalOrders = request.getAttribute("totalOrders");
    Object totalRevenue = request.getAttribute("totalRevenue");
    List<SalesSummary> trend = (List<SalesSummary>) request.getAttribute("trend");
    List<ProductSales> ranking = (List<ProductSales>) request.getAttribute("ranking");
%>
<main>
    <div class="container">
        <h2>管理后台</h2>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value"><%= totalUsers != null ? totalUsers : 0 %></div>
                <div class="stat-label">注册用户</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= totalMerchants != null ? totalMerchants : 0 %></div>
                <div class="stat-label">商家数量</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= totalOrders != null ? totalOrders : 0 %></div>
                <div class="stat-label">总订单数</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">&yen;<%= totalRevenue != null ? totalRevenue : "0.00" %></div>
                <div class="stat-label">总营收</div>
            </div>
        </div>

        <div class="chart-row">
            <div class="chart-box">
                <h3>近30天销售趋势</h3>
                <div id="trendChart" style="width:100%;height:350px;"></div>
            </div>
            <div class="chart-box">
                <h3>商品销售排行 Top 10</h3>
                <div id="rankChart" style="width:100%;height:350px;"></div>
            </div>
        </div>
    </div>
</main>
<script>
    // 销售趋势
    var trendDates = [<%
        if (trend != null) for (int i = 0; i < trend.size(); i++) {
            if (i > 0) out.print(",");
            out.print("'" + trend.get(i).getSaleDate() + "'");
        }
    %>];
    var trendAmounts = [<%
        if (trend != null) for (int i = 0; i < trend.size(); i++) {
            if (i > 0) out.print(",");
            out.print(trend.get(i).getTotalAmount());
        }
    %>];
    var trendChart = echarts.init(document.getElementById('trendChart'));
    trendChart.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'category', data: trendDates },
        yAxis: { type: 'value', name: '金额(元)' },
        series: [{ data: trendAmounts, type: 'line', smooth: true, areaStyle: { opacity: 0.15 } }]
    });

    // 排行榜
    var rankNames = [<%
        if (ranking != null) for (int i = 0; i < Math.min(10, ranking.size()); i++) {
            if (i > 0) out.print(",");
            out.print("'" + ranking.get(i).getProductName().replace("'", "\\'") + "'");
        }
    %>];
    var rankValues = [<%
        if (ranking != null) for (int i = 0; i < Math.min(10, ranking.size()); i++) {
            if (i > 0) out.print(",");
            out.print(ranking.get(i).getTotalQuantity());
        }
    %>];
    var rankChart = echarts.init(document.getElementById('rankChart'));
    rankChart.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: { type: 'value', name: '销量' },
        yAxis: { type: 'category', data: rankNames.reverse() },
        series: [{ data: rankValues.reverse(), type: 'bar' }]
    });

    window.addEventListener('resize', function() {
        trendChart.resize();
        rankChart.resize();
    });
</script>
</body>
</html>
