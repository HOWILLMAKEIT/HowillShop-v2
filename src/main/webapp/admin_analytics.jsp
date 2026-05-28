<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.javaweb.shop.model.SalesSummary" %>
<%@ page import="com.javaweb.shop.model.CategorySales" %>
<%@ page import="com.javaweb.shop.model.StockDistribution" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>数据分析</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
    <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
</head>
<body>
<jsp:include page="/partials/navbar.jsp" />
<%
    List<SalesSummary> trend = (List<SalesSummary>) request.getAttribute("trend");
    List<CategorySales> catSales = (List<CategorySales>) request.getAttribute("categorySales");
    List<SalesSummary> hourly = (List<SalesSummary>) request.getAttribute("hourly");
    List<SalesSummary> statusStats = (List<SalesSummary>) request.getAttribute("statusStats");
    List<StockDistribution> stockStats = (List<StockDistribution>) request.getAttribute("stockStats");
    String range = (String) request.getAttribute("range");
    String growthRate = (String) request.getAttribute("growthRate");
    List<String> forecastDates = (List<String>) request.getAttribute("forecastDates");
    List<BigDecimal> forecastAmounts = (List<BigDecimal>) request.getAttribute("forecastAmounts");
%>
<main>
    <div class="container">
        <h2>数据分析</h2>
        <div style="margin:1rem 0">
            <a class="btn<%= "week".equals(range) ? "" : " secondary" %>" href="?range=week">近7天</a>
            <a class="btn<%= "month".equals(range) ? "" : " secondary" %>" href="?range=month">近30天</a>
            <a class="btn<%= "quarter".equals(range) ? "" : " secondary" %>" href="?range=quarter">近90天</a>
        </div>

        <div class="chart-row">
            <div class="chart-box">
                <h3>销售趋势 <span class="muted" style="font-size:0.85em">（前后半段环比：<%= growthRate != null ? growthRate : "-" %>）</span></h3>
                <div id="trendChart" style="width:100%;height:350px;"></div>
            </div>
            <div class="chart-box">
                <h3>品类销售分布</h3>
                <div id="pieChart" style="width:100%;height:350px;"></div>
            </div>
        </div>

        <h3>今日异常检测（按小时）</h3>
        <table>
            <thead>
                <tr><th>时段</th><th>订单数</th><th>金额</th><th>状态</th></tr>
            </thead>
            <tbody>
                <% if (hourly != null) {
                    double avgOrders = hourly.stream().mapToLong(SalesSummary::getOrderCount).average().orElse(0);
                    for (int i = 0; i < hourly.size(); i++) {
                        SalesSummary h = hourly.get(i);
                        boolean anomaly = avgOrders > 0 && h.getOrderCount() > avgOrders * 3;
                %>
                <tr<%= anomaly ? " style=\"background:#fff3f3\"" : "" %>>
                    <td><%= i %>:00</td>
                    <td><%= h.getOrderCount() %></td>
                    <td><%= h.getTotalAmount() %></td>
                    <td><%= anomaly ? "<span style=\"color:red;font-weight:bold\">异常</span>" : "正常" %></td>
                </tr>
                <% }
                } %>
            </tbody>
        </table>

        <h3>订单状态分布</h3>
        <table>
            <thead>
                <tr><th>支付状态</th><th>发货状态</th><th>订单数</th><th>金额</th></tr>
            </thead>
            <tbody>
                <% if (statusStats != null) {
                    for (SalesSummary s : statusStats) {
                %>
                <tr>
                    <td><%= s.getPayStatus() != null ? s.getPayStatus() : "-" %></td>
                    <td><%= s.getShipStatus() != null ? s.getShipStatus() : "-" %></td>
                    <td><%= s.getOrderCount() %></td>
                    <td><%= s.getTotalAmount() %></td>
                </tr>
                <% }
                } %>
            </tbody>
        </table>

        <h3>库存分布</h3>
        <table>
            <thead>
                <tr><th>库存区间</th><th>商品数量</th></tr>
            </thead>
            <tbody>
                <% if (stockStats != null) {
                    for (StockDistribution s : stockStats) {
                %>
                <tr>
                    <td><%= s.getStockRange() %></td>
                    <td><%= s.getProductCount() %></td>
                </tr>
                <% }
                } %>
            </tbody>
        </table>
    </div>
</main>
<script>
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
    // 预测数据：未来 3 天日期和均值
    var fcDates = [<%
        if (forecastDates != null) for (int i = 0; i < forecastDates.size(); i++) {
            if (i > 0) out.print(",");
            out.print("'" + forecastDates.get(i) + "'");
        }
    %>];
    var fcAmounts = [<%
        if (forecastAmounts != null) for (int i = 0; i < forecastAmounts.size(); i++) {
            if (i > 0) out.print(",");
            out.print(forecastAmounts.get(i));
        }
    %>];
    var allDates = trendDates.concat(fcDates);
    // 预测系列：前 N-1 个点为 null，从历史末尾衔接
    var forecastSeries = [];
    if (fcAmounts.length > 0) {
        var padded = new Array(trendAmounts.length - 1).fill(null);
        padded.push(trendAmounts[trendAmounts.length - 1]);
        forecastSeries = padded.concat(fcAmounts);
    }
    var tc = echarts.init(document.getElementById('trendChart'));
    var seriesList = [{ data: trendAmounts, type: 'line', smooth: true, areaStyle: { opacity: 0.15 }, name: '实际销售' }];
    if (forecastSeries.length > 0) {
        seriesList.push({ data: forecastSeries, type: 'line', smooth: true, lineStyle: { type: 'dashed', color: '#ee6666' }, itemStyle: { color: '#ee6666' }, name: '预测(7日均值)' });
    }
    tc.setOption({
        tooltip: { trigger: 'axis' },
        legend: { bottom: 0 },
        xAxis: { type: 'category', data: allDates },
        yAxis: { type: 'value', name: '金额(元)' },
        series: seriesList
    });

    var pieData = [<%
        if (catSales != null) for (int i = 0; i < catSales.size(); i++) {
            if (i > 0) out.print(",");
            CategorySales c = catSales.get(i);
            out.print("{name:'" + c.getCategoryName().replace("'", "\\'") + "',value:" + c.getTotalAmount() + "}");
        }
    %>];
    var pc = echarts.init(document.getElementById('pieChart'));
    pc.setOption({
        tooltip: { trigger: 'item' },
        series: [{ type: 'pie', radius: ['40%', '70%'], data: pieData, label: { formatter: '{b}: {d}%' } }]
    });

    window.addEventListener('resize', function() { tc.resize(); pc.resize(); });
</script>
</body>
</html>
