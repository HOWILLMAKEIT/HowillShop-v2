-- ====================================================================
-- 修复后的测试数据 SQL 脚本
-- 修复了跨商家问题、订单状态问题、价格错误等
-- 执行方式：mysql -u root -p javaweb_shop < test_data_fixed.sql
-- ====================================================================

USE javaweb_shop;

-- 清理旧数据（可选）
-- DELETE FROM user_purchase_logs WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38);
-- DELETE FROM user_login_logs WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38);
-- DELETE FROM user_browse_logs WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38);
-- DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38));
-- DELETE FROM orders WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38);
-- DELETE FROM carts WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38);
-- DELETE FROM products WHERE merchant_id IN (24, 25, 26, 27, 28);
-- DELETE FROM users WHERE id IN (24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38);

-- ====================================================================
-- 1. 创建商家账号（5个）
-- ====================================================================
INSERT INTO users (username, password_hash, email, role, status) VALUES
('潮流服饰', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'fashion1@test.com', 'MERCHANT', 1),
('数码专营', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'digital1@test.com', 'MERCHANT', 1),
('家居生活', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'home1@test.com', 'MERCHANT', 1),
('美妆护肤', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'beauty@test.com', 'MERCHANT', 1),
('运动户外', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sports@test.com', 'MERCHANT', 1);

-- ====================================================================
-- 2. 创建用户账号（10个）
-- ====================================================================
INSERT INTO users (username, password_hash, email, role, status) VALUES
('张伟', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'zhangwei@test.com', 'CUSTOMER', 1),
('李娜', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'lina@test.com', 'CUSTOMER', 1),
('王强', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'wangqiang@test.com', 'CUSTOMER', 1),
('刘芳', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'liufang@test.com', 'CUSTOMER', 1),
('陈明', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'chenming@test.com', 'CUSTOMER', 1),
('杨静', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'yangjing@test.com', 'CUSTOMER', 1),
('赵磊', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'zhaolei@test.com', 'CUSTOMER', 1),
('孙丽', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'sunli@test.com', 'CUSTOMER', 1),
('周杰', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'zhoujie@test.com', 'CUSTOMER', 1),
('吴敏', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'wumin@test.com', 'CUSTOMER', 1);

-- ====================================================================
-- 3. 创建商品（16款，价格正确）
-- ====================================================================
-- 潮流服饰 (ID=24) - 分类1 - 3款商品
INSERT INTO products (category_id, merchant_id, name, price, stock, status, description) VALUES
(1, 24, '春季新款休闲外套', 399.00, 80, 1, '2026春季新品，舒适面料，时尚百搭'),
(1, 24, '纯棉基础款T恤', 89.00, 150, 1, '100%纯棉，透气舒适，多色可选'),
(1, 24, '修身牛仔裤', 199.00, 120, 1, '经典修身版型，舒适弹性面料');

-- 数码专营 (ID=25) - 分类3 - 4款商品
INSERT INTO products (category_id, merchant_id, name, price, stock, status, description) VALUES
(3, 25, '无线蓝牙耳机', 299.00, 100, 1, '主动降噪，30小时续航，支持快充'),
(3, 25, '智能手环运动版', 199.00, 80, 1, '心率监测，睡眠分析，50米防水'),
(3, 25, '便携充电宝', 129.00, 200, 1, '20000mAh大容量，支持快充'),
(3, 25, '无线充电器', 79.00, 150, 1, '支持多设备同时充电');

-- 家居生活 (ID=26) - 分类2 - 3款商品
INSERT INTO products (category_id, merchant_id, name, price, stock, status, description) VALUES
(2, 26, '北欧风简约台灯', 159.00, 60, 1, '护眼LED光源，三档调光，极简设计'),
(2, 26, '记忆棉枕头', 129.00, 100, 1, '慢回弹记忆棉，颈椎保护'),
(2, 26, '简约置物架', 89.00, 80, 1, '多层收纳，安装简便');

-- 美妆护肤 (ID=27) - 分类6 - 3款商品
INSERT INTO products (category_id, merchant_id, name, price, stock, status, description) VALUES
(6, 27, '保湿面膜套装', 199.00, 120, 1, '深层补水，修护肌肤，10片装'),
(6, 27, '修护精华液', 299.00, 80, 1, '修复受损肌肤，提亮肤色，30ml'),
(6, 27, '温和洁面乳', 79.00, 150, 1, '温和清洁，不紧绷，150ml');

-- 运动户外 (ID=28) - 分类4 - 3款商品
INSERT INTO products (category_id, merchant_id, name, price, stock, status, description) VALUES
(4, 28, '专业跑步鞋', 499.00, 60, 1, '缓震回弹，透气舒适，适合长跑'),
(4, 28, '运动健身背包', 199.00, 80, 1, '大容量设计，干湿分离，多功能口袋'),
(4, 28, '瑜伽垫套装', 129.00, 100, 1, '防滑环保材质，附带弹力带和收纳袋');

-- ====================================================================
-- 4. 创建浏览记录（171条，分布在4-5月）
-- ====================================================================
-- 张伟 (ID=29) - 18条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(29, 27, 3, 45, '2026-04-02 10:30:00'), (29, 28, 3, 60, '2026-04-02 11:00:00'),
(29, 29, 3, 30, '2026-04-05 14:20:00'), (29, 27, 3, 55, '2026-04-08 09:15:00'),
(29, 30, 3, 40, '2026-04-12 16:45:00'), (29, 28, 3, 70, '2026-04-15 10:00:00'),
(29, 24, 1, 35, '2026-04-18 13:30:00'), (29, 25, 1, 25, '2026-04-22 11:15:00'),
(29, 27, 3, 50, '2026-04-25 15:00:00'), (29, 29, 3, 45, '2026-04-28 12:30:00'),
(29, 30, 3, 35, '2026-05-02 09:00:00'), (29, 28, 3, 65, '2026-05-05 14:20:00'),
(29, 27, 3, 40, '2026-05-08 11:00:00'), (29, 29, 3, 55, '2026-05-12 16:00:00'),
(29, 24, 1, 30, '2026-05-15 13:45:00'), (29, 31, 2, 45, '2026-05-18 10:30:00'),
(29, 27, 3, 60, '2026-05-22 14:15:00'), (29, 28, 3, 50, '2026-05-25 09:40:00'),
(29, 29, 3, 70, '2026-05-28 12:00:00');

-- 李娜 (ID=30) - 18条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(30, 34, 6, 60, '2026-04-01 15:00:00'), (30, 35, 6, 75, '2026-04-01 15:30:00'),
(30, 36, 6, 45, '2026-04-06 10:20:00'), (30, 34, 6, 80, '2026-04-10 14:00:00'),
(30, 35, 6, 55, '2026-04-14 11:30:00'), (30, 36, 6, 40, '2026-04-18 16:00:00'),
(30, 25, 1, 35, '2026-04-21 13:00:00'), (30, 26, 1, 30, '2026-04-24 10:45:00'),
(30, 34, 6, 65, '2026-04-27 15:20:00'), (30, 35, 6, 70, '2026-05-01 11:00:00'),
(30, 36, 6, 50, '2026-05-05 14:30:00'), (30, 34, 6, 85, '2026-05-09 09:15:00'),
(30, 31, 2, 40, '2026-05-13 12:00:00'), (30, 32, 2, 35, '2026-05-16 15:30:00'),
(30, 35, 6, 60, '2026-05-19 10:00:00'), (30, 34, 6, 75, '2026-05-23 13:45:00'),
(30, 36, 6, 55, '2026-05-26 11:20:00'), (30, 25, 1, 30, '2026-05-29 14:00:00');

-- 王强 (ID=31) - 16条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(31, 37, 4, 50, '2026-04-03 09:00:00'), (31, 38, 4, 45, '2026-04-03 09:30:00'),
(31, 39, 4, 60, '2026-04-07 14:15:00'), (31, 37, 4, 70, '2026-04-11 10:00:00'),
(31, 38, 4, 55, '2026-04-15 13:20:00'), (31, 39, 4, 40, '2026-04-19 16:00:00'),
(31, 27, 3, 35, '2026-04-22 11:00:00'), (31, 28, 3, 45, '2026-04-26 14:30:00'),
(31, 37, 4, 65, '2026-04-30 09:45:00'), (31, 38, 4, 50, '2026-05-04 12:00:00'),
(31, 39, 4, 75, '2026-05-08 15:00:00'), (31, 27, 3, 30, '2026-05-12 10:30:00'),
(31, 37, 4, 60, '2026-05-16 13:15:00'), (31, 28, 3, 40, '2026-05-20 11:00:00'),
(31, 38, 4, 55, '2026-05-24 14:45:00'), (31, 39, 4, 70, '2026-05-28 09:00:00');

-- 刘芳 (ID=32) - 17条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(32, 31, 2, 55, '2026-04-04 10:00:00'), (32, 32, 2, 65, '2026-04-04 10:40:00'),
(32, 33, 2, 45, '2026-04-08 13:30:00'), (32, 31, 2, 70, '2026-04-12 11:00:00'),
(32, 32, 2, 60, '2026-04-16 14:15:00'), (32, 33, 2, 50, '2026-04-20 09:30:00'),
(32, 34, 6, 35, '2026-04-23 12:00:00'), (32, 35, 6, 40, '2026-04-27 15:00:00'),
(32, 31, 2, 75, '2026-05-01 10:45:00'), (32, 32, 2, 80, '2026-05-05 13:00:00'),
(32, 33, 2, 65, '2026-05-09 11:30:00'), (32, 36, 6, 30, '2026-05-13 14:00:00'),
(32, 31, 2, 85, '2026-05-17 09:15:00'), (32, 32, 2, 70, '2026-05-21 12:30:00'),
(32, 33, 2, 55, '2026-05-25 15:00:00'), (32, 31, 2, 60, '2026-05-29 10:00:00');

-- 陈明 (ID=33) - 16条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(33, 24, 1, 40, '2026-04-05 11:00:00'), (33, 27, 3, 55, '2026-04-05 11:30:00'),
(33, 31, 2, 45, '2026-04-09 14:00:00'), (33, 34, 6, 60, '2026-04-09 14:30:00'),
(33, 37, 4, 35, '2026-04-13 10:00:00'), (33, 25, 1, 50, '2026-04-17 13:15:00'),
(33, 28, 3, 65, '2026-04-21 11:00:00'), (33, 32, 2, 40, '2026-04-25 14:30:00'),
(33, 35, 6, 55, '2026-04-29 09:00:00'), (33, 38, 4, 70, '2026-05-03 12:00:00'),
(33, 24, 1, 45, '2026-05-07 15:00:00'), (33, 27, 3, 60, '2026-05-11 10:30:00'),
(33, 31, 2, 50, '2026-05-15 13:45:00'), (33, 34, 6, 75, '2026-05-19 11:00:00'),
(33, 37, 4, 40, '2026-05-23 14:15:00'), (33, 25, 1, 65, '2026-05-27 09:30:00');

-- 杨静 (ID=34) - 18条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(34, 24, 1, 70, '2026-04-06 12:00:00'), (34, 25, 1, 55, '2026-04-06 12:30:00'),
(34, 26, 1, 60, '2026-04-10 15:00:00'), (34, 24, 1, 80, '2026-04-14 11:00:00'),
(34, 25, 1, 65, '2026-04-18 13:30:00'), (34, 26, 1, 75, '2026-04-22 10:00:00'),
(34, 34, 6, 40, '2026-04-25 14:00:00'), (34, 35, 6, 45, '2026-04-29 11:30:00'),
(34, 24, 1, 85, '2026-05-03 09:00:00'), (34, 25, 1, 70, '2026-05-07 12:00:00'),
(34, 26, 1, 90, '2026-05-11 15:00:00'), (34, 36, 6, 35, '2026-05-15 10:30:00'),
(34, 24, 1, 75, '2026-05-19 13:00:00'), (34, 25, 1, 80, '2026-05-23 11:00:00'),
(34, 26, 1, 65, '2026-05-27 14:30:00'), (34, 24, 1, 70, '2026-05-30 09:00:00');

-- 赵磊 (ID=35) - 17条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(35, 27, 3, 50, '2026-04-07 10:30:00'), (35, 28, 3, 65, '2026-04-07 11:00:00'),
(35, 29, 3, 45, '2026-04-11 14:00:00'), (35, 30, 3, 60, '2026-04-11 14:30:00'),
(35, 27, 3, 70, '2026-04-15 11:00:00'), (35, 28, 3, 55, '2026-04-19 13:15:00'),
(35, 37, 4, 40, '2026-04-23 10:00:00'), (35, 38, 4, 45, '2026-04-27 12:30:00'),
(35, 29, 3, 75, '2026-05-01 15:00:00'), (35, 30, 3, 80, '2026-05-05 11:00:00'),
(35, 27, 3, 65, '2026-05-09 13:30:00'), (35, 28, 3, 70, '2026-05-13 10:00:00'),
(35, 37, 4, 50, '2026-05-17 14:00:00'), (35, 29, 3, 85, '2026-05-21 11:30:00'),
(35, 30, 3, 60, '2026-05-25 09:00:00'), (35, 27, 3, 75, '2026-05-29 12:15:00');

-- 孙丽 (ID=36) - 15条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(36, 34, 6, 75, '2026-04-08 11:00:00'), (36, 35, 6, 90, '2026-04-08 11:30:00'),
(36, 36, 6, 60, '2026-04-12 14:00:00'), (36, 34, 6, 85, '2026-04-16 10:00:00'),
(36, 35, 6, 70, '2026-04-20 13:00:00'), (36, 36, 6, 65, '2026-04-24 11:30:00'),
(36, 25, 1, 40, '2026-04-27 14:00:00'), (36, 26, 1, 35, '2026-05-01 10:30:00'),
(36, 34, 6, 95, '2026-05-05 13:00:00'), (36, 35, 6, 80, '2026-05-09 15:00:00'),
(36, 36, 6, 75, '2026-05-13 11:00:00'), (36, 31, 2, 45, '2026-05-17 09:30:00'),
(36, 34, 6, 85, '2026-05-21 12:00:00'), (36, 35, 6, 90, '2026-05-25 14:30:00'),
(36, 36, 6, 70, '2026-05-29 10:00:00');

-- 周杰 (ID=37) - 16条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(37, 37, 4, 55, '2026-04-09 09:30:00'), (37, 38, 4, 70, '2026-04-09 10:00:00'),
(37, 39, 4, 65, '2026-04-13 13:00:00'), (37, 37, 4, 80, '2026-04-17 10:30:00'),
(37, 38, 4, 60, '2026-04-21 14:00:00'), (37, 39, 4, 75, '2026-04-25 11:00:00'),
(37, 27, 3, 40, '2026-04-28 12:30:00'), (37, 28, 3, 50, '2026-05-02 15:00:00'),
(37, 37, 4, 85, '2026-05-06 10:00:00'), (37, 38, 4, 70, '2026-05-10 13:00:00'),
(37, 39, 4, 90, '2026-05-14 11:30:00'), (37, 27, 3, 45, '2026-05-18 14:00:00'),
(37, 37, 4, 75, '2026-05-22 09:15:00'), (37, 28, 3, 60, '2026-05-26 12:00:00'),
(37, 39, 4, 80, '2026-05-30 10:30:00');

-- 吴敏 (ID=38) - 21条记录
INSERT INTO user_browse_logs (user_id, product_id, category_id, dwell_time_seconds, browsed_at) VALUES
(38, 24, 1, 45, '2026-04-10 12:00:00'), (38, 31, 2, 55, '2026-04-10 12:30:00'),
(38, 34, 6, 60, '2026-04-14 14:30:00'), (38, 37, 4, 50, '2026-04-14 15:00:00'),
(38, 25, 1, 65, '2026-04-18 10:00:00'), (38, 32, 2, 70, '2026-04-18 10:30:00'),
(38, 35, 6, 55, '2026-04-22 13:00:00'), (38, 38, 4, 60, '2026-04-22 13:30:00'),
(38, 26, 1, 75, '2026-04-26 11:00:00'), (38, 33, 2, 80, '2026-04-26 11:30:00'),
(38, 36, 6, 65, '2026-05-01 14:00:00'), (38, 39, 4, 70, '2026-05-01 14:30:00'),
(38, 24, 1, 85, '2026-05-05 09:30:00'), (38, 31, 2, 90, '2026-05-05 10:00:00'),
(38, 34, 6, 60, '2026-05-09 12:30:00'), (38, 37, 4, 75, '2026-05-09 13:00:00'),
(38, 25, 1, 80, '2026-05-13 10:00:00'), (38, 32, 2, 85, '2026-05-13 10:30:00'),
(38, 35, 6, 70, '2026-05-17 13:30:00'), (38, 38, 4, 65, '2026-05-17 14:00:00'),
(38, 26, 1, 75, '2026-05-21 11:00:00'), (38, 33, 2, 80, '2026-05-21 11:30:00'),
(38, 36, 6, 90, '2026-05-25 14:00:00'), (38, 39, 4, 85, '2026-05-25 14:30:00');

-- ====================================================================
-- 5. 创建订单（32笔，状态正确，无跨商家问题）
-- ====================================================================
-- 张伟 (ID=29) - 3个订单 - 从商家25购买数码产品
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260408001', 29, 25, 498.00, 'COMPLETED', 'PAID', 'SHIPPED', '张伟', '13800001001', '北京市朝阳区xxx', '2026-04-08 10:00:00');
SET @o1 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o1, 27, '无线蓝牙耳机', 1, 299.00, 299.00),
(@o1, 28, '智能手环运动版', 1, 199.00, 199.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260422001', 29, 25, 208.00, 'COMPLETED', 'PAID', 'SHIPPED', '张伟', '13800001001', '北京市朝阳区xxx', '2026-04-22 14:00:00');
SET @o2 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o2, 29, '便携充电宝', 1, 129.00, 129.00),
(@o2, 30, '无线充电器', 1, 79.00, 79.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260512001', 29, 24, 687.00, 'PAID', 'PAID', 'PENDING', '张伟', '13800001001', '北京市朝阳区xxx', '2026-05-12 11:00:00');
SET @o3 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o3, 24, '春季新款休闲外套', 1, 399.00, 399.00),
(@o3, 25, '纯棉基础款T恤', 1, 89.00, 89.00),
(@o3, 26, '修身牛仔裤', 1, 199.00, 199.00);

-- 李娜 (ID=30) - 4个订单 - 从商家27和24购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260410001', 30, 27, 199.00, 'COMPLETED', 'PAID', 'SHIPPED', '李娜', '13800001002', '上海市浦东新区xxx', '2026-04-10 15:00:00');
SET @o4 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o4, 34, '保湿面膜套装', 1, 199.00, 199.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260418001', 30, 27, 776.00, 'COMPLETED', 'PAID', 'SHIPPED', '李娜', '13800001002', '上海市浦东新区xxx', '2026-04-18 13:00:00');
SET @o5 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o5, 34, '保湿面膜套装', 2, 199.00, 398.00),
(@o5, 36, '温和洁面乳', 1, 79.00, 79.00),
(@o5, 35, '修护精华液', 1, 299.00, 299.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260505001', 30, 27, 378.00, 'SHIPPED', 'PAID', 'SHIPPED', '李娜', '13800001002', '上海市浦东新区xxx', '2026-05-05 10:00:00');
SET @o6 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o6, 35, '修护精华液', 1, 299.00, 299.00),
(@o6, 36, '温和洁面乳', 1, 79.00, 79.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260520001', 30, 24, 687.00, 'PAID', 'PAID', 'PENDING', '李娜', '13800001002', '上海市浦东新区xxx', '2026-05-20 14:00:00');
SET @o7 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o7, 24, '春季新款休闲外套', 1, 399.00, 399.00),
(@o7, 25, '纯棉基础款T恤', 1, 89.00, 89.00),
(@o7, 26, '修身牛仔裤', 1, 199.00, 199.00);

-- 王强 (ID=31) - 3个订单 - 从商家28和25购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260411001', 31, 28, 698.00, 'COMPLETED', 'PAID', 'SHIPPED', '王强', '13800001003', '广州市天河区xxx', '2026-04-11 09:00:00');
SET @o8 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o8, 37, '专业跑步鞋', 1, 499.00, 499.00),
(@o8, 38, '运动健身背包', 1, 199.00, 199.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260419001', 31, 28, 129.00, 'COMPLETED', 'PAID', 'SHIPPED', '王强', '13800001003', '广州市天河区xxx', '2026-04-19 14:00:00');
SET @o9 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o9, 39, '瑜伽垫套装', 1, 129.00, 129.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260508001', 31, 25, 498.00, 'SHIPPED', 'PAID', 'SHIPPED', '王强', '13800001003', '广州市天河区xxx', '2026-05-08 13:00:00');
SET @o10 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o10, 27, '无线蓝牙耳机', 1, 299.00, 299.00),
(@o10, 28, '智能手环运动版', 1, 199.00, 199.00);

-- 刘芳 (ID=32) - 2个订单 - 从商家26购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260412001', 32, 26, 377.00, 'COMPLETED', 'PAID', 'SHIPPED', '刘芳', '13800001004', '深圳市南山区xxx', '2026-04-12 11:00:00');
SET @o11 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o11, 31, '北欧风简约台灯', 1, 159.00, 159.00),
(@o11, 32, '记忆棉枕头', 1, 129.00, 129.00),
(@o11, 33, '简约置物架', 1, 89.00, 89.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260509001', 32, 26, 218.00, 'PAID', 'PAID', 'PENDING', '刘芳', '13800001004', '深圳市南山区xxx', '2026-05-09 10:00:00');
SET @o12 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o12, 32, '记忆棉枕头', 1, 129.00, 129.00),
(@o12, 33, '简约置物架', 1, 89.00, 89.00);

-- 陈明 (ID=33) - 4个订单 - 从不同商家购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260413001', 33, 24, 488.00, 'COMPLETED', 'PAID', 'SHIPPED', '陈明', '13800001005', '杭州市西湖区xxx', '2026-04-13 10:00:00');
SET @o13 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o13, 24, '春季新款休闲外套', 1, 399.00, 399.00),
(@o13, 25, '纯棉基础款T恤', 1, 89.00, 89.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260421001', 33, 25, 378.00, 'COMPLETED', 'PAID', 'SHIPPED', '陈明', '13800001005', '杭州市西湖区xxx', '2026-04-21 13:00:00');
SET @o14 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o14, 27, '无线蓝牙耳机', 1, 299.00, 299.00),
(@o14, 30, '无线充电器', 1, 79.00, 79.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260503001', 33, 26, 377.00, 'SHIPPED', 'PAID', 'SHIPPED', '陈明', '13800001005', '杭州市西湖区xxx', '2026-05-03 14:00:00');
SET @o15 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o15, 31, '北欧风简约台灯', 1, 159.00, 159.00),
(@o15, 32, '记忆棉枕头', 1, 129.00, 129.00),
(@o15, 33, '简约置物架', 1, 89.00, 89.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260516001', 33, 27, 378.00, 'PAID', 'PAID', 'PENDING', '陈明', '13800001005', '杭州市西湖区xxx', '2026-05-16 11:00:00');
SET @o16 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o16, 35, '修护精华液', 1, 299.00, 299.00),
(@o16, 36, '温和洁面乳', 1, 79.00, 79.00);

-- 杨静 (ID=34) - 3个订单 - 从商家24和27购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260414001', 34, 24, 776.00, 'COMPLETED', 'PAID', 'SHIPPED', '杨静', '13800001006', '成都市武侯区xxx', '2026-04-14 12:00:00');
SET @o17 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o17, 24, '春季新款休闲外套', 1, 399.00, 399.00),
(@o17, 25, '纯棉基础款T恤', 2, 89.00, 178.00),
(@o17, 26, '修身牛仔裤', 1, 199.00, 199.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260425001', 34, 27, 577.00, 'COMPLETED', 'PAID', 'SHIPPED', '杨静', '13800001006', '成都市武侯区xxx', '2026-04-25 15:00:00');
SET @o18 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o18, 34, '保湿面膜套装', 1, 199.00, 199.00),
(@o18, 35, '修护精华液', 1, 299.00, 299.00),
(@o18, 36, '温和洁面乳', 1, 79.00, 79.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260511001', 34, 24, 687.00, 'PAID', 'PAID', 'PENDING', '杨静', '13800001006', '成都市武侯区xxx', '2026-05-11 14:00:00');
SET @o19 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o19, 24, '春季新款休闲外套', 1, 399.00, 399.00),
(@o19, 25, '纯棉基础款T恤', 1, 89.00, 89.00),
(@o19, 26, '修身牛仔裤', 1, 199.00, 199.00);

-- 赵磊 (ID=35) - 2个订单 - 从商家25购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260415001', 35, 25, 577.00, 'COMPLETED', 'PAID', 'SHIPPED', '赵磊', '13800001007', '南京市鼓楼区xxx', '2026-04-15 11:00:00');
SET @o20 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o20, 27, '无线蓝牙耳机', 1, 299.00, 299.00),
(@o20, 28, '智能手环运动版', 1, 199.00, 199.00),
(@o20, 30, '无线充电器', 1, 79.00, 79.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260506001', 35, 25, 577.00, 'PAID', 'PAID', 'PENDING', '赵磊', '13800001007', '南京市鼓楼区xxx', '2026-05-06 10:00:00');
SET @o21 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o21, 27, '无线蓝牙耳机', 1, 299.00, 299.00),
(@o21, 30, '无线充电器', 1, 79.00, 79.00);

-- 孙丽 (ID=36) - 3个订单 - 从商家27和24购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260416001', 36, 27, 498.00, 'COMPLETED', 'PAID', 'SHIPPED', '孙丽', '13800001008', '武汉市江汉区xxx', '2026-04-16 13:00:00');
SET @o22 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o22, 34, '保湿面膜套装', 1, 199.00, 199.00),
(@o22, 35, '修护精华液', 1, 299.00, 299.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260424001', 36, 27, 278.00, 'COMPLETED', 'PAID', 'SHIPPED', '孙丽', '13800001008', '武汉市江汉区xxx', '2026-04-24 10:00:00');
SET @o23 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o23, 34, '保湿面膜套装', 1, 199.00, 199.00),
(@o23, 36, '温和洁面乳', 1, 79.00, 79.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260513001', 36, 24, 687.00, 'PAID', 'PAID', 'PENDING', '孙丽', '13800001008', '武汉市江汉区xxx', '2026-05-13 11:00:00');
SET @o24 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o24, 24, '春季新款休闲外套', 1, 399.00, 399.00),
(@o24, 25, '纯棉基础款T恤', 1, 89.00, 89.00),
(@o24, 26, '修身牛仔裤', 1, 199.00, 199.00);

-- 周杰 (ID=37) - 3个订单 - 从商家28和25购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260417001', 37, 28, 698.00, 'COMPLETED', 'PAID', 'SHIPPED', '周杰', '13800001009', '西安市雁塔区xxx', '2026-04-17 09:00:00');
SET @o25 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o25, 37, '专业跑步鞋', 1, 499.00, 499.00),
(@o25, 38, '运动健身背包', 1, 199.00, 199.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260426001', 37, 28, 328.00, 'COMPLETED', 'PAID', 'SHIPPED', '周杰', '13800001009', '西安市雁塔区xxx', '2026-04-26 14:00:00');
SET @o26 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o26, 38, '运动健身背包', 1, 199.00, 199.00),
(@o26, 39, '瑜伽垫套装', 1, 129.00, 129.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260514001', 37, 25, 378.00, 'PAID', 'PAID', 'PENDING', '周杰', '13800001009', '西安市雁塔区xxx', '2026-05-14 10:00:00');
SET @o27 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o27, 27, '无线蓝牙耳机', 1, 299.00, 299.00),
(@o27, 30, '无线充电器', 1, 79.00, 79.00);

-- 吴敏 (ID=38) - 5个订单 - 从不同商家购买
INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260418001', 38, 24, 488.00, 'COMPLETED', 'PAID', 'SHIPPED', '吴敏', '13800001010', '重庆市渝北区xxx', '2026-04-18 11:00:00');
SET @o28 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o28, 24, '春季新款休闲外套', 1, 399.00, 399.00),
(@o28, 25, '纯棉基础款T恤', 1, 89.00, 89.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260427001', 38, 26, 377.00, 'COMPLETED', 'PAID', 'SHIPPED', '吴敏', '13800001010', '重庆市渝北区xxx', '2026-04-27 13:00:00');
SET @o29 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o29, 31, '北欧风简约台灯', 1, 159.00, 159.00),
(@o29, 32, '记忆棉枕头', 1, 129.00, 129.00),
(@o29, 33, '简约置物架', 1, 89.00, 89.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260501001', 38, 27, 378.00, 'SHIPPED', 'PAID', 'SHIPPED', '吴敏', '13800001010', '重庆市渝北区xxx', '2026-05-01 10:00:00');
SET @o30 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o30, 35, '修护精华液', 1, 299.00, 299.00),
(@o30, 36, '温和洁面乳', 1, 79.00, 79.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260509002', 38, 28, 698.00, 'PAID', 'PAID', 'PENDING', '吴敏', '13800001010', '重庆市渝北区xxx', '2026-05-09 12:00:00');
SET @o31 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o31, 37, '专业跑步鞋', 1, 499.00, 499.00),
(@o31, 38, '运动健身背包', 1, 199.00, 199.00);

INSERT INTO orders (order_no, user_id, merchant_id, total_amount, order_status, pay_status, ship_status, receiver_name, receiver_phone, receiver_address, created_at) VALUES
('ORD20260517001', 38, 24, 687.00, 'CREATED', 'UNPAID', 'PENDING', '吴敏', '13800001010', '重庆市渝北区xxx', '2026-05-17 13:00:00');
SET @o32 = LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal) VALUES
(@o32, 24, '春季新款休闲外套', 1, 399.00, 399.00),
(@o32, 25, '纯棉基础款T恤', 1, 89.00, 89.00),
(@o32, 26, '修身牛仔裤', 1, 199.00, 199.00);

-- ====================================================================
-- 6. 创建购买记录（基于订单）
-- ====================================================================
INSERT INTO user_purchase_logs (user_id, order_id, product_id, category_id, unit_price, quantity, purchased_at)
SELECT o.user_id, o.id as order_id, oi.product_id, p.category_id, oi.unit_price, oi.quantity, o.created_at as purchased_at
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38)
AND o.pay_status = 'PAID';

-- ====================================================================
-- 7. 创建登录记录（80条）
-- ====================================================================
INSERT INTO user_login_logs (user_id, ip_address, user_agent, login_at) VALUES
-- 张伟 (8次)
(29, '113.65.28.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-02 10:00:00'),
(29, '113.65.28.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-08 09:30:00'),
(29, '113.65.28.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-15 14:00:00'),
(29, '113.65.28.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-22 13:30:00'),
(29, '113.65.28.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-05 10:00:00'),
(29, '113.65.28.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-12 09:00:00'),
(29, '113.65.28.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-20 14:30:00'),
(29, '113.65.28.123', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-28 11:00:00'),
-- 李娜 (8次)
(30, '183.14.200.45', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-04-01 14:00:00'),
(30, '183.14.200.45', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-04-10 13:30:00'),
(30, '183.14.200.45', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-04-18 12:00:00'),
(30, '183.14.200.45', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-05-01 10:30:00'),
(30, '183.14.200.45', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-05-05 15:00:00'),
(30, '183.14.200.45', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-05-13 11:30:00'),
(30, '183.14.200.45', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-05-20 14:00:00'),
(30, '183.14.200.45', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-05-25 09:30:00'),
-- 王强 (8次)
(31, '210.21.98.76', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120', '2026-04-03 08:30:00'),
(31, '210.21.98.76', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120', '2026-04-11 09:00:00'),
(31, '210.21.98.76', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120', '2026-04-19 13:00:00'),
(31, '210.21.98.76', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120', '2026-05-03 10:30:00'),
(31, '210.21.98.76', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120', '2026-05-08 14:00:00'),
(31, '210.21.98.76', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120', '2026-05-15 11:00:00'),
(31, '210.21.98.76', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120', '2026-05-22 13:30:00'),
(31, '210.21.98.76', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Edge/120', '2026-05-28 09:00:00'),
-- 刘芳 (8次)
(32, '120.236.145.89', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-04 11:00:00'),
(32, '120.236.145.89', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-12 10:00:00'),
(32, '120.236.145.89', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-20 13:00:00'),
(32, '120.236.145.89', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-02 09:00:00'),
(32, '120.236.145.89', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-09 12:30:00'),
(32, '120.236.145.89', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-16 10:00:00'),
(32, '120.236.145.89', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-23 13:30:00'),
(32, '120.236.145.89', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-29 08:30:00'),
-- 陈明 (8次)
(33, '59.172.88.123', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-04-05 13:00:00'),
(33, '59.172.88.123', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-04-13 11:30:00'),
(33, '59.172.88.123', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-04-21 12:00:00'),
(33, '59.172.88.123', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-05-03 10:00:00'),
(33, '59.172.88.123', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-05-10 13:30:00'),
(33, '59.172.88.123', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-05-16 11:00:00'),
(33, '59.172.88.123', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-05-21 14:00:00'),
(33, '59.172.88.123', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-05-27 09:30:00'),
-- 杨静 (8次)
(34, '202.96.134.56', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-04-06 10:30:00'),
(34, '202.96.134.56', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-04-14 11:00:00'),
(34, '202.96.134.56', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-04-22 13:00:00'),
(34, '202.96.134.56', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-04-30 09:30:00'),
(34, '202.96.134.56', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-05-07 12:00:00'),
(34, '202.96.134.56', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-05-11 14:30:00'),
(34, '202.96.134.56', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-05-18 10:00:00'),
(34, '202.96.134.56', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-05-25 13:00:00'),
-- 赵磊 (8次)
(35, '112.65.210.98', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120', '2026-04-07 09:00:00'),
(35, '112.65.210.98', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120', '2026-04-15 11:00:00'),
(35, '112.65.210.98', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120', '2026-04-23 13:30:00'),
(35, '112.65.210.98', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120', '2026-05-01 10:00:00'),
(35, '112.65.210.98', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120', '2026-05-06 14:00:00'),
(35, '112.65.210.98', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120', '2026-05-13 11:30:00'),
(35, '112.65.210.98', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120', '2026-05-19 13:00:00'),
(35, '112.65.210.98', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/120', '2026-05-26 09:00:00'),
-- 孙丽 (8次)
(36, '218.92.176.54', 'Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-08 12:00:00'),
(36, '218.92.176.54', 'Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-16 10:30:00'),
(36, '218.92.176.54', 'Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-24 14:00:00'),
(36, '218.92.176.54', 'Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-02 11:00:00'),
(36, '218.92.176.54', 'Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-09 13:00:00'),
(36, '218.92.176.54', 'Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-13 14:30:00'),
(36, '218.92.176.54', 'Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-20 10:00:00'),
(36, '218.92.176.54', 'Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-27 12:30:00'),
-- 周杰 (8次)
(37, '125.78.234.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-09 08:00:00'),
(37, '125.78.234.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-17 09:30:00'),
(37, '125.78.234.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-26 12:00:00'),
(37, '125.78.234.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-04 10:30:00'),
(37, '125.78.234.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-11 13:00:00'),
(37, '125.78.234.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-14 14:30:00'),
(37, '125.78.234.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-21 11:00:00'),
(37, '125.78.234.12', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-28 08:30:00'),
-- 吴敏 (8次)
(38, '101.86.145.234', 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120', '2026-04-10 11:00:00'),
(38, '101.86.145.234', 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120', '2026-04-18 12:00:00'),
(38, '101.86.145.234', 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120', '2026-04-27 13:30:00'),
(38, '101.86.145.234', 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120', '2026-05-04 10:00:00'),
(38, '101.86.145.234', 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120', '2026-05-09 11:30:00'),
(38, '101.86.145.234', 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120', '2026-05-17 13:00:00'),
(38, '101.86.145.234', 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120', '2026-05-23 14:30:00'),
(38, '101.86.145.234', 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120', '2026-05-30 09:00:00');

-- ====================================================================
-- 7b. 创建商家登录记录（28条）
-- ====================================================================
INSERT INTO user_login_logs (user_id, ip_address, user_agent, login_at) VALUES
-- 潮流服饰 (ID=24) - 6次
(24, '120.36.100.10', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-04-01 09:00:00'),
(24, '120.36.100.10', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-04-10 10:00:00'),
(24, '120.36.100.10', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-04-20 14:00:00'),
(24, '120.36.100.10', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-05-05 09:30:00'),
(24, '120.36.100.10', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-05-15 11:00:00'),
(24, '120.36.100.10', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/120', '2026-05-28 08:30:00'),
-- 数码专营 (ID=25) - 6次
(25, '183.6.200.20', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-01 09:30:00'),
(25, '183.6.200.20', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-08 08:00:00'),
(25, '183.6.200.20', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-04-15 13:00:00'),
(25, '183.6.200.20', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-01 10:00:00'),
(25, '183.6.200.20', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-10 09:00:00'),
(25, '183.6.200.20', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120', '2026-05-25 14:00:00'),
-- 家居生活 (ID=26) - 5次
(26, '211.139.50.30', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-04-01 10:00:00'),
(26, '211.139.50.30', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-04-12 09:00:00'),
(26, '211.139.50.30', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-04-25 11:00:00'),
(26, '211.139.50.30', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-05-05 14:30:00'),
(26, '211.139.50.30', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/14', '2026-05-20 09:00:00'),
-- 美妆护肤 (ID=27) - 6次
(27, '58.60.150.40', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-01 10:30:00'),
(27, '58.60.150.40', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-10 11:00:00'),
(27, '58.60.150.40', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-04-18 09:30:00'),
(27, '58.60.150.40', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-01 13:00:00'),
(27, '58.60.150.40', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-15 10:30:00'),
(27, '58.60.150.40', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605', '2026-05-27 15:00:00'),
-- 运动户外 (ID=28) - 5次
(28, '14.23.80.50', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-04-01 11:00:00'),
(28, '14.23.80.50', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-04-11 08:30:00'),
(28, '14.23.80.50', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-04-22 10:00:00'),
(28, '14.23.80.50', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-05-05 09:00:00'),
(28, '14.23.80.50', 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/120', '2026-05-18 13:30:00');

-- ====================================================================
-- 7c. 创建商家操作日志（61条）
-- ====================================================================
INSERT INTO operation_logs (operator_id, operator_role, action, detail, ip_address, created_at) VALUES
-- 潮流服饰 (ID=24) - 11条
(24, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 春季新款休闲外套', '120.36.100.10', '2026-04-01 09:10:00'),
(24, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 纯棉基础款T恤', '120.36.100.10', '2026-04-01 09:15:00'),
(24, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 修身牛仔裤', '120.36.100.10', '2026-04-01 09:20:00'),
(24, 'MERCHANT', 'ADD_CATEGORY', '添加分类: 服饰推荐', '120.36.100.10', '2026-04-05 10:00:00'),
(24, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 春季新款休闲外套', '120.36.100.10', '2026-04-10 10:30:00'),
(24, 'MERCHANT', 'SHIP', '发货订单 (陈明)', '120.36.100.10', '2026-04-14 09:30:00'),
(24, 'MERCHANT', 'SHIP', '发货订单 (杨静)', '120.36.100.10', '2026-04-15 10:00:00'),
(24, 'MERCHANT', 'SHIP', '发货订单 (吴敏)', '120.36.100.10', '2026-04-24 09:00:00'),
(24, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 纯棉基础款T恤', '120.36.100.10', '2026-05-05 10:00:00'),
(24, 'MERCHANT', 'TOGGLE_CATEGORY', '切换分类状态', '120.36.100.10', '2026-05-10 10:00:00'),
-- 数码专营 (ID=25) - 13条
(25, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 无线蓝牙耳机', '183.6.200.20', '2026-04-01 09:40:00'),
(25, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 智能手环运动版', '183.6.200.20', '2026-04-01 09:45:00'),
(25, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 便携充电宝', '183.6.200.20', '2026-04-01 09:50:00'),
(25, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 无线充电器', '183.6.200.20', '2026-04-01 09:55:00'),
(25, 'MERCHANT', 'TOGGLE_CATEGORY', '切换分类状态', '183.6.200.20', '2026-04-08 09:30:00'),
(25, 'MERCHANT', 'SHIP', '发货订单 (张伟)', '183.6.200.20', '2026-04-09 10:00:00'),
(25, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 无线蓝牙耳机', '183.6.200.20', '2026-04-15 14:00:00'),
(25, 'MERCHANT', 'SHIP', '发货订单 (赵磊)', '183.6.200.20', '2026-04-16 09:00:00'),
(25, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 智能手环运动版', '183.6.200.20', '2026-04-22 09:30:00'),
(25, 'MERCHANT', 'SHIP', '发货订单 (陈明)', '183.6.200.20', '2026-04-22 15:00:00'),
(25, 'MERCHANT', 'SHIP', '发货订单 (张伟)', '183.6.200.20', '2026-04-23 10:00:00'),
(25, 'MERCHANT', 'SHIP', '发货订单 (王强)', '183.6.200.20', '2026-05-09 10:00:00'),
(25, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 便携充电宝', '183.6.200.20', '2026-05-10 10:00:00'),
-- 家居生活 (ID=26) - 9条
(26, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 北欧风简约台灯', '211.139.50.30', '2026-04-01 10:10:00'),
(26, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 记忆棉枕头', '211.139.50.30', '2026-04-01 10:15:00'),
(26, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 简约置物架', '211.139.50.30', '2026-04-01 10:20:00'),
(26, 'MERCHANT', 'ADD_CATEGORY', '添加分类: 家居好物', '211.139.50.30', '2026-04-03 14:00:00'),
(26, 'MERCHANT', 'SHIP', '发货订单 (刘芳)', '211.139.50.30', '2026-04-13 10:00:00'),
(26, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 北欧风简约台灯', '211.139.50.30', '2026-04-25 11:30:00'),
(26, 'MERCHANT', 'SHIP', '发货订单 (吴敏)', '211.139.50.30', '2026-04-28 09:00:00'),
(26, 'MERCHANT', 'SHIP', '发货订单 (陈明)', '211.139.50.30', '2026-05-04 10:00:00'),
(26, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 记忆棉枕头', '211.139.50.30', '2026-05-20 09:30:00'),
-- 美妆护肤 (ID=27) - 14条
(27, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 保湿面膜套装', '58.60.150.40', '2026-04-01 10:40:00'),
(27, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 修护精华液', '58.60.150.40', '2026-04-01 10:45:00'),
(27, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 温和洁面乳', '58.60.150.40', '2026-04-01 10:50:00'),
(27, 'MERCHANT', 'ADD_CATEGORY', '添加分类: 热门美妆', '58.60.150.40', '2026-04-04 11:00:00'),
(27, 'MERCHANT', 'SHIP', '发货订单 (李娜)', '58.60.150.40', '2026-04-11 09:00:00'),
(27, 'MERCHANT', 'SHIP', '发货订单 (孙丽)', '58.60.150.40', '2026-04-17 10:00:00'),
(27, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 保湿面膜套装', '58.60.150.40', '2026-04-18 10:00:00'),
(27, 'MERCHANT', 'SHIP', '发货订单 (李娜)', '58.60.150.40', '2026-04-19 11:00:00'),
(27, 'MERCHANT', 'SHIP', '发货订单 (孙丽)', '58.60.150.40', '2026-04-25 09:00:00'),
(27, 'MERCHANT', 'SHIP', '发货订单 (杨静)', '58.60.150.40', '2026-04-26 10:00:00'),
(27, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 修护精华液', '58.60.150.40', '2026-05-01 14:00:00'),
(27, 'MERCHANT', 'SHIP', '发货订单 (吴敏)', '58.60.150.40', '2026-05-02 09:00:00'),
(27, 'MERCHANT', 'SHIP', '发货订单 (李娜)', '58.60.150.40', '2026-05-06 09:30:00'),
(27, 'MERCHANT', 'TOGGLE_CATEGORY', '切换分类状态', '58.60.150.40', '2026-05-15 11:00:00'),
-- 运动户外 (ID=28) - 10条
(28, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 专业跑步鞋', '14.23.80.50', '2026-04-01 11:10:00'),
(28, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 运动健身背包', '14.23.80.50', '2026-04-01 11:15:00'),
(28, 'MERCHANT', 'ADD_PRODUCT', '新增商品: 瑜伽垫套装', '14.23.80.50', '2026-04-01 11:20:00'),
(28, 'MERCHANT', 'ADD_CATEGORY', '添加分类: 运动必备', '14.23.80.50', '2026-04-02 15:00:00'),
(28, 'MERCHANT', 'SHIP', '发货订单 (王强)', '14.23.80.50', '2026-04-12 10:00:00'),
(28, 'MERCHANT', 'SHIP', '发货订单 (周杰)', '14.23.80.50', '2026-04-18 09:00:00'),
(28, 'MERCHANT', 'SHIP', '发货订单 (王强)', '14.23.80.50', '2026-04-20 10:00:00'),
(28, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 专业跑步鞋', '14.23.80.50', '2026-04-22 11:00:00'),
(28, 'MERCHANT', 'SHIP', '发货订单 (周杰)', '14.23.80.50', '2026-04-27 10:00:00'),
(28, 'MERCHANT', 'UPDATE_PRODUCT', '更新商品: 瑜伽垫套装', '14.23.80.50', '2026-05-05 09:30:00');

-- ====================================================================
-- 8. 根据 login_logs 回填 users.last_login_at
-- ====================================================================
UPDATE users u
JOIN (
  SELECT user_id, MAX(login_at) AS last_login
  FROM user_login_logs
  GROUP BY user_id
) ll ON u.id = ll.user_id
SET u.last_login_at = ll.last_login;

-- ====================================================================
-- 执行完成提示
-- ====================================================================
SELECT '✅ 修复后的测试数据创建完成！' as '';
SELECT '=== 数据统计 ===' as '';
SELECT CONCAT('商家账号: ', COUNT(*)) as '' FROM users WHERE role = 'MERCHANT' AND username IN ('潮流服饰', '数码专营', '家居生活', '美妆护肤', '运动户外')
UNION ALL
SELECT CONCAT('用户账号: ', COUNT(*)) FROM users WHERE role = 'CUSTOMER' AND username IN ('张伟', '李娜', '王强', '刘芳', '陈明', '杨静', '赵磊', '孙丽', '周杰', '吴敏')
UNION ALL
SELECT CONCAT('商品数量: ', COUNT(*)) FROM products WHERE merchant_id IN (24, 25, 26, 27, 28)
UNION ALL
SELECT CONCAT('浏览记录: ', COUNT(*)) FROM user_browse_logs WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38)
UNION ALL
SELECT CONCAT('购买记录: ', COUNT(*)) FROM user_purchase_logs WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38)
UNION ALL
SELECT CONCAT('订单数量: ', COUNT(*)) FROM orders WHERE user_id IN (29, 30, 31, 32, 33, 34, 35, 36, 37, 38)
UNION ALL
SELECT CONCAT('登录记录: ', COUNT(*)) FROM user_login_logs WHERE user_id IN (24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38)
UNION ALL
SELECT CONCAT('操作日志: ', COUNT(*)) FROM operation_logs WHERE operator_id IN (24, 25, 26, 27, 28);

SELECT '' as '';
SELECT '=== 测试账号信息 ===' as '';
SELECT '所有账号密码均为: 123456' as '';
SELECT '' as '';
SELECT '商家账号:' as '';
SELECT username as '账号', email as '邮箱' FROM users WHERE role = 'MERCHANT' AND username IN ('潮流服饰', '数码专营', '家居生活', '美妆护肤', '运动户外');
SELECT '' as '';
SELECT '用户账号:' as '';
SELECT username as '账号', email as '邮箱' FROM users WHERE role = 'CUSTOMER' AND username IN ('张伟', '李娜', '王强', '刘芳', '陈明', '杨静', '赵磊', '孙丽', '周杰', '吴敏');
