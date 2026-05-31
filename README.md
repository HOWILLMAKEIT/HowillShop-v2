<div align="center">
  <h1>HowillSHOP 小昊商城</h1>
  <p>基于 Java Web 的多角色电商平台（消费者 / 商家 / 管理员）</p>
  <p>在基础购物功能上追加大数据分析与推荐系统</p>
  <p>
    <img src="https://img.shields.io/badge/JAVA-11-000000?style=flat-square&labelColor=000000&color=000000" alt="Java 11" />
    <img src="https://img.shields.io/badge/TOMCAT-9.x-f8c04d?style=flat-square&labelColor=f8c04d&color=f8c04d" alt="Tomcat 9" />
    <img src="https://img.shields.io/badge/SERVLET-4.0.1-2f6db3?style=flat-square&labelColor=2f6db3&color=2f6db3" alt="Servlet" />
    <img src="https://img.shields.io/badge/JSP-2.3.3-2f6db3?style=flat-square&labelColor=2f6db3&color=2f6db3" alt="JSP" />
    <img src="https://img.shields.io/badge/MYSQL-8.x-1d6f42?style=flat-square&labelColor=1d6f42&color=1d6f42" alt="MySQL" />
  </p>
  <p>
    <img src="https://img.shields.io/badge/ECHARTS-5-aa344d?style=flat-square&labelColor=aa344d&color=aa344d" alt="ECharts 5" />
    <img src="https://img.shields.io/badge/MAVEN-3.9+-c71a36?style=flat-square&labelColor=c71a36&color=c71a36" alt="Maven" />
    <img src="https://img.shields.io/badge/HIKARICP-5.x-4a4a4a?style=flat-square&labelColor=4a4a4a&color=4a4a4a" alt="HikariCP" />
    <img src="https://img.shields.io/badge/JAVAMAIL-2.0.1-4a4a4a?style=flat-square&labelColor=4a4a4a&color=4a4a4a" alt="JavaMail" />
    <img src="https://img.shields.io/badge/ALIYUN%20OSS-3.17.4-ff6a00?style=flat-square&labelColor=ff6a00&color=ff6a00" alt="Aliyun OSS" />
  </p>
</div>

<p align="center">
  <img src="assets/mainpage.png" alt="HowillSHOP 首页" width="860" />
</p>

<p align="center">
  <img src="assets/基本架构.png" alt="HowillSHOP 基本架构" width="860" />
</p>

<p align="center">
  <b>姓名</b>：郭昊 &nbsp;|&nbsp; <b>班级</b>：23 网络工程 &nbsp;|&nbsp; <b>学号</b>：202330450471
</p>

<p align="center">
  <b>在线演示</b>：见实验报告
</p>

---

<p align="center">
  <a href="#功能特性">功能特性</a>
  · <a href="#技术栈">技术栈</a>
  · <a href="#快速开始">快速开始</a>
  · <a href="#目录结构">目录结构</a>
  · <a href="#版本演进">版本演进</a>
</p>

## 功能特性

### [版本一（基础电商）](https://github.com/HOWILLMAKEIT/HowillSHOP)

- 用户/商家注册、登录、注销（BCrypt 加密）
- 商品展示、分类筛选、关键词搜索、分页
- 购物车增删改查、同款合并、总价计算
- 结算与支付（模拟），多商家拆单
- 订单列表与订单详情，确认收货
- 商家商品管理（仅管理自己的商品）
- 商家发货 + JavaMail 邮件通知（含商品明细）
- 阿里云 OSS 图片上传、私有读签名 URL
- 销售统计报表

### 版本二（大数据分析 + 推荐系统）

**数据采集（4 类日志表）：**
- 登录日志：记录用户 IP、User-Agent、登录时间
- 浏览日志：记录商品浏览、停留时长（前端 sendBeacon 上报）
- 购买日志：记录支付商品、单价、数量、分类
- 操作日志：记录管理员/商家后台操作

**数据分析与可视化（ECharts）：**
- 销售趋势图：支持 7 天 / 30 天 / 90 天切换，含移动平均预测
- 环比增长率计算
- 品类销售饼图
- 商品销量排行（Top N 柱状图）
- 异常检测：按小时维度统计，超均值 3 倍自动标红预警
- 用户画像：地域推断（IP → 省市）、消费力分级、品类偏好
- 订单状态分布、库存区间分布

**推荐系统（双引擎）：**
- 关联推荐："浏览过此商品的人也买了"（基于共浏览行为，商品详情页底部展示）
- 协同过滤：Item-based CF（基于购买共现频次，热门商品兜底，独立推荐页面）

**管理后台（Admin 角色）：**
- 仪表盘 KPI（用户数、订单数、营收）+ 趋势图 + Top10 排行
- 用户管理：添加/删除商家、重置密码、启禁账号
- 分类管理：添加、删除、启停
- 系统日志：4 类日志 tab 切换查看

## 技术栈

| 层次 | 技术 |
|------|------|
| 后端 | Java 11 + Servlet 4.0.1 + JSP 2.3.3 |
| 数据库 | MySQL 8 + HikariCP 5.1.0 |
| 前端 | JSP + ECharts 5（CDN）+ CSS |
| 邮件 | JavaMail 2.0.1（SMTP / QQ 邮箱）|
| 图片存储 | 阿里云 OSS 3.17.4（签名 URL）|
| 密码加密 | jBCrypt 0.4 |
| 数据分析 | ECharts 可视化 + 移动平均预测 + SQL 聚合 |
| 推荐算法 | Item-based 协同过滤（购买共现频次）|
| 构建 | Maven 3.9+ |
| 部署 | Tomcat 9 + Nginx 反向代理 + 阿里云 ECS |

## 快速开始

### 1) 环境准备

- JDK 11
- Maven 3.9+
- Tomcat 9
- MySQL 8

### 2) 初始化数据库

```bash
mysql -u root -p < db/schema.sql
mysql -u root -p javaweb_shop < db/seed.sql
mysql -u root -p javaweb_shop < db/migration_v2.sql
mysql -u root -p javaweb_shop < db/test_data_fixed.sql
```

### 3) 配置 .env

在项目根目录创建 `.env`，覆盖默认的 `db.properties` / `mail.properties` / `oss.properties`，详见实验报告。

### 4) 开发模式（Tomcat 热重载）

详见实验报告中的开发环境配置章节。

### 5) 打包部署

详见 [部署指南](部署指南.md)。

### 6) 自动化测试

项目提供 AI 辅助生成的自动化测试脚本，覆盖 63 项功能检查：

```bash
pip install requests beautifulsoup4 pymysql
python test_checklist.py
```

详见 [自动化测试说明](自动化测试说明.md)。

## 测试账号

数据库初始化后会自动创建管理员、商家和用户账号，详见 [用户.md](用户.md)。

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | admin | admin123 | 系统内置 |
| 商家 / 用户 | 潮流服饰、张伟 等 | 123456 | 共 5 个商家 + 10 个用户 |

## 目录结构

```
db/                              # 数据库脚本
  ├── schema.sql                 # 建库建表
  ├── seed.sql                   # 基础种子数据（分类）
  ├── migration_v2.sql           # 版本二迁移（4 张日志表 + Admin）
  └── test_data_fixed.sql        # 版本二测试数据（商家/用户/日志）

src/main/java/com/javaweb/shop/
  ├── web/                       # Servlet 控制器
  │   ├── ProductServlet         # 商品列表/详情 + 浏览埋点
  │   ├── CartServlet            # 购物车
  │   ├── CheckoutServlet        # 结算
  │   ├── PaymentServlet         # 支付 + 购买日志
  │   ├── AdminDashboardServlet  # 管理仪表盘
  │   ├── AdminAnalyticsServlet  # 数据分析（趋势/饼图/异常检测）
  │   ├── AdminUserProfileServlet# 用户画像
  │   ├── RecommendationServlet  # 个性化推荐
  │   └── ...
  ├── service/                   # 业务逻辑
  │   ├── RecommendationService  # 推荐引擎（关联 + 协同过滤）
  │   ├── AnalyticsService       # 数据分析
  │   ├── LogService             # 日志写入（静默异常）
  │   └── ...
  ├── dao/                       # 数据访问（JDBC）
  ├── model/                     # 实体模型 / DTO
  ├── infra/db/                  # DataSourceFactory（HikariCP）
  └── util/                      # PasswordHasher（jBCrypt）

src/main/resources/              # db/mail/oss 配置文件
src/main/webapp/                 # JSP 页面 + 静态资源 + WEB-INF
```

## 版本演进

| 版本 | 内容 |
|------|------|
| **v1.0** | 基础电商：注册登录、商品浏览、购物车、模拟支付、多商家拆单、发货邮件、销售统计 — [GitHub](https://github.com/HOWILLMAKEIT/HowillSHOP) |
| **v2.0** | 追加数据采集（4 类日志）、Admin 管理后台、ECharts 数据分析与可视化、双引擎推荐系统 |

## License

MIT
