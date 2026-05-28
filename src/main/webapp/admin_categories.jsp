<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.javaweb.shop.model.Category" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>分类管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<jsp:include page="/partials/navbar.jsp" />
<main>
    <div class="container">
        <div class="card">
            <div class="top-nav">
                <div>
                    <h1>分类管理</h1>
                    <div class="muted">添加、删除或启停商品分类</div>
                </div>
            </div>
            <div class="message"><%= session.getAttribute("categoryMessage") != null ? session.getAttribute("categoryMessage") : "" %></div>
            <div class="error"><%= session.getAttribute("categoryError") != null ? session.getAttribute("categoryError") : "" %></div>
<%
    session.removeAttribute("categoryMessage");
    session.removeAttribute("categoryError");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
%>
            <div class="section">
                <h2>新增分类</h2>
                <form method="post" action="${pageContext.request.contextPath}/admin/categories">
                    <input type="hidden" name="action" value="add">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="name">分类名称</label>
                            <input id="name" name="name" required>
                        </div>
                        <div class="form-group">
                            <label for="sortOrder">排序权重</label>
                            <input id="sortOrder" name="sortOrder" type="number" value="0">
                        </div>
                    </div>
                    <div class="actions">
                        <button type="submit">添加分类</button>
                    </div>
                </form>
            </div>

            <div class="section">
                <h2>分类列表</h2>
                <% if (categories == null || categories.isEmpty()) { %>
                    <p class="muted">暂无分类。</p>
                <% } else { %>
                    <table>
                        <thead>
                        <tr><th>ID</th><th>名称</th><th>排序</th><th>状态</th><th>操作</th></tr>
                        </thead>
                        <tbody>
                        <% for (Category cat : categories) { %>
                        <tr>
                            <td><%= cat.getId() %></td>
                            <td><%= cat.getName() %></td>
                            <td><%= cat.getSortOrder() %></td>
                            <td><%= cat.getStatus() == 1 ? "启用" : "停用" %></td>
                            <td>
                                <form class="inline-form" method="post" action="${pageContext.request.contextPath}/admin/categories" style="display:inline">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="categoryId" value="<%= cat.getId() %>">
                                    <button type="submit" class="btn secondary"><%= cat.getStatus() == 1 ? "停用" : "启用" %></button>
                                </form>
                                <form class="inline-form" method="post" action="${pageContext.request.contextPath}/admin/categories" style="display:inline">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="categoryId" value="<%= cat.getId() %>">
                                    <button type="submit" onclick="return confirm('确认删除该分类？')"><%= cat.getStatus() == 1 ? "删除" : "删除" %></button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>
</main>
</body>
</html>
