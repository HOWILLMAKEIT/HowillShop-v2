<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.javaweb.shop.model.User" %>
<%@ page import="java.util.List" %>
<%!
    private String roleLabel(String role) {
        if ("ADMIN".equals(role)) return "管理员";
        if ("MERCHANT".equals(role)) return "商家";
        return "用户";
    }
    private String statusLabel(int status) {
        return status == 1 ? "启用" : "禁用";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>用户管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/style.css">
</head>
<body>
<jsp:include page="/partials/navbar.jsp" />
<%
    List<User> users = (List<User>) request.getAttribute("users");
    String error = (String) session.getAttribute("userManageError");
    session.removeAttribute("userManageError");
%>
<main>
    <div class="container">
        <h2>用户管理</h2>
        <% if (error != null) { %>
            <div class="alert error"><%= error %></div>
        <% } %>
        <div class="card" style="margin-bottom:1.5rem">
            <h3>新增销售人员</h3>
            <form method="post" class="form-grid">
                <input type="hidden" name="action" value="createMerchant">
                <div class="form-group">
                    <label for="username">用户名</label>
                    <input id="username" name="username" required>
                </div>
                <div class="form-group">
                    <label for="email">邮箱</label>
                    <input id="email" name="email" type="email" required>
                </div>
                <div class="form-group">
                    <label for="phone">手机号</label>
                    <input id="phone" name="phone">
                </div>
                <div class="form-group">
                    <label for="password">初始密码</label>
                    <input id="password" name="password" type="password" minlength="6" required>
                </div>
                <div class="actions">
                    <button type="submit">添加销售人员</button>
                </div>
            </form>
        </div>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>用户名</th>
                    <th>邮箱</th>
                    <th>角色</th>
                    <th>状态</th>
                    <th>注册时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <% for (User u : users) { %>
                <tr>
                    <td><%= u.getId() %></td>
                    <td><%= u.getUsername() %></td>
                    <td><%= u.getEmail() %></td>
                    <td><%= roleLabel(u.getRole()) %></td>
                    <td><%= statusLabel(u.getStatus()) %></td>
                    <td><%= u.getCreatedAt() %></td>
                    <td>
                        <% if (!"ADMIN".equals(u.getRole())) { %>
                        <form method="post" style="display:inline">
                            <input type="hidden" name="userId" value="<%= u.getId() %>">
                            <input type="hidden" name="action" value="resetPassword">
                            <button type="submit" class="btn small" onclick="return confirm('确认重置密码为123456？')">重置密码</button>
                        </form>
                        <form method="post" style="display:inline">
                            <input type="hidden" name="userId" value="<%= u.getId() %>">
                            <input type="hidden" name="action" value="toggleStatus">
                            <button type="submit" class="btn small secondary"><%= u.getStatus() == 1 ? "禁用" : "启用" %></button>
                        </form>
                        <% if ("MERCHANT".equals(u.getRole())) { %>
                        <form method="post" style="display:inline">
                            <input type="hidden" name="userId" value="<%= u.getId() %>">
                            <input type="hidden" name="action" value="deleteMerchant">
                            <button type="submit" class="btn small danger" onclick="return confirm('确认删除该销售人员账号？关联商品和订单会保留，但不再绑定该账号。')">删除</button>
                        </form>
                        <% } %>
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</main>
</body>
</html>
