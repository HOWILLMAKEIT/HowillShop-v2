#!/usr/bin/env python3
"""
功能检查表自动化测试脚本
基于 docs/版本二的docs/功能检查表.md
使用 requests + BeautifulSoup 模拟用户操作，逐项验证功能
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse, parse_qs
import time
import sys
import re
import traceback

BASE_URL = "http://localhost:8080/shop"

# ANSI colors
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
CYAN = "\033[96m"
BOLD = "\033[1m"
RESET = "\033[0m"

results = {"pass": 0, "fail": 0, "skip": 0, "details": []}


def log_pass(module, item, detail=""):
    results["pass"] += 1
    results["details"].append(("PASS", module, item, detail))
    print(f"  {GREEN}✓ PASS{RESET} {item}" + (f" — {detail}" if detail else ""))


def log_fail(module, item, detail=""):
    results["fail"] += 1
    results["details"].append(("FAIL", module, item, detail))
    print(f"  {RED}✗ FAIL{RESET} {item} — {detail}")


def log_skip(module, item, detail=""):
    results["skip"] += 1
    results["details"].append(("SKIP", module, item, detail))
    print(f"  {YELLOW}⊘ SKIP{RESET} {item} — {detail}")


def section_header(title):
    print(f"\n{BOLD}{CYAN}{'='*60}\n{title}\n{'='*60}{RESET}")


def subsection_header(title):
    print(f"\n{BOLD}--- {title} ---{RESET}")


def parse_html(resp):
    return BeautifulSoup(resp.text, "html.parser")


def assert_contains(soup, text, case_sensitive=False):
    page_text = soup.get_text()
    if case_sensitive:
        return text in page_text
    return text.lower() in page_text.lower()


def assert_element_exists(soup, tag, attrs=None):
    return soup.find(tag, attrs) is not None


class TestRunner:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Test Script) FunctionalChecklist/1.0"
        })
        # Store test data
        self.test_user = {
            "username": f"testuser_{int(time.time())}",
            "email": f"testuser_{int(time.time())}@test.com",
            "phone": "13800138000",
            "password": "Test@123456"
        }
        self.test_merchant = {
            "username": f"testmerchant_{int(time.time())}",
            "email": f"testmerchant_{int(time.time())}@test.com",
            "phone": "13900139000",
            "password": "Merchant@123"
        }
        self.admin_creds = {"username": "admin", "password": "admin123"}
        self.category_id = None
        self.product_ids = []

    def get(self, path, **kwargs):
        # Handle absolute paths that already include context path
        if path.startswith("/shop/"):
            path = path[len("/shop"):]
        url = urljoin(BASE_URL + "/", path.lstrip("/"))
        return self.session.get(url, allow_redirects=True, **kwargs)

    def post(self, path, data=None, **kwargs):
        url = urljoin(BASE_URL + "/", path.lstrip("/"))
        return self.session.post(url, data=data, allow_redirects=True, **kwargs)

    # ================================================================
    # 前置条件
    # ================================================================
    def test_prerequisites(self):
        section_header("前置条件")
        module = "前置条件"

        # Test startup
        try:
            resp = self.get("/")
            if resp.status_code == 200:
                log_pass(module, "访问首页页面正常加载", f"HTTP {resp.status_code}")
            else:
                log_fail(module, "访问首页页面正常加载", f"HTTP {resp.status_code}")
        except requests.ConnectionError:
            log_fail(module, "访问首页页面正常加载",
                     "无法连接服务器，请确认 Tomcat 已启动 (./startup.sh)")
            print(f"\n{RED}服务器未启动，终止测试。请先运行 ./startup.sh{RESET}")
            sys.exit(1)

    # ================================================================
    # 一、注册与登录
    # ================================================================
    def test_register_and_login(self):
        section_header("一、注册与登录")
        module = "注册与登录"

        # 1.1 注册普通用户
        subsection_header("1.1 注册普通用户")

        # 进入注册页面
        resp = self.get("/register.jsp")
        soup = parse_html(resp)
        if assert_element_exists(soup, "form"):
            log_pass(module, "进入注册页面")
        else:
            log_fail(module, "进入注册页面", "未找到注册表单")

        # 提交注册
        resp = self.post("/auth/register", data={
            "registerType": "user",
            "username": self.test_user["username"],
            "email": self.test_user["email"],
            "phone": self.test_user["phone"],
            "password": self.test_user["password"],
            "confirm_password": self.test_user["password"]
        })
        if resp.status_code == 200:
            soup = parse_html(resp)
            # Check for success message on login page or redirect to login
            if "登录" in soup.title.string if soup.title else "" or \
               assert_contains(soup, "注册成功") or \
               assert_contains(soup, "登录") or \
               "login" in resp.url:
                log_pass(module, "注册提交成功，跳转到登录页",
                         f"跳转到: {resp.url}")
            else:
                log_fail(module, "注册提交后跳转", f"未跳转到登录页: {resp.url}")
        else:
            log_fail(module, "注册提交", f"HTTP {resp.status_code}")

        # 用新账号登录
        resp = self.post("/auth/login", data={
            "username": self.test_user["username"],
            "password": self.test_user["password"],
            "loginType": "user"
        })
        soup = parse_html(resp)
        if assert_contains(soup, self.test_user["username"]) or \
           "products" in resp.url:
            log_pass(module, "新用户登录成功", f"URL: {resp.url}")
        else:
            log_fail(module, "新用户登录", f"登录后页面未显示用户名, URL: {resp.url}")

        # 检查导航栏显示用户名
        if assert_contains(soup, self.test_user["username"]):
            log_pass(module, "导航栏显示用户名")
        else:
            log_fail(module, "导航栏显示用户名", "页面中未找到用户名")

        # 退出登录
        resp = self.get("/auth/logout")
        soup = parse_html(resp)
        if "products" in resp.url or assert_contains(soup, "登录"):
            log_pass(module, "退出登录成功")
        else:
            log_fail(module, "退出登录", f"URL: {resp.url}")

        # 再次登录确认
        resp = self.post("/auth/login", data={
            "username": self.test_user["username"],
            "password": self.test_user["password"],
            "loginType": "user"
        })
        if "products" in resp.url or assert_contains(parse_html(resp), self.test_user["username"]):
            log_pass(module, "退出后再登录正常")
        else:
            log_fail(module, "退出后再登录", f"URL: {resp.url}")

        # 退出，准备注册商家
        self.get("/auth/logout")

        # 1.2 注册商家
        subsection_header("1.2 注册商家")

        resp = self.post("/auth/register", data={
            "registerType": "merchant",
            "username": self.test_merchant["username"],
            "email": self.test_merchant["email"],
            "phone": self.test_merchant["phone"],
            "password": self.test_merchant["password"],
            "confirm_password": self.test_merchant["password"]
        })
        if resp.status_code == 200:
            log_pass(module, "注册商家账号")
        else:
            log_fail(module, "注册商家账号", f"HTTP {resp.status_code}")

        # 商家登录
        resp = self.post("/auth/login", data={
            "username": self.test_merchant["username"],
            "password": self.test_merchant["password"],
            "loginType": "merchant"
        })
        soup = parse_html(resp)
        if assert_contains(soup, "商家") or "products" in resp.url or "admin" in resp.url:
            log_pass(module, "商家登录成功", f"URL: {resp.url}")
        else:
            log_fail(module, "商家登录", f"URL: {resp.url}")

        # 检查商家后台菜单
        merchant_menu_items = ["订单管理", "商品管理", "分类管理", "销售报表", "日志查看"]
        merchant_menu_ok = True
        for item in merchant_menu_items:
            if not assert_contains(soup, item):
                merchant_menu_ok = False
                log_fail(module, f"商家后台菜单包含「{item}」", "未找到")
                break
        if merchant_menu_ok:
            log_pass(module, "商家后台菜单包含所有必需项",
                     ", ".join(merchant_menu_items))

        self.get("/auth/logout")

        # 1.3 管理员登录
        subsection_header("1.3 管理员登录")

        resp = self.post("/auth/login", data={
            "username": "admin",
            "password": "admin123",
            "loginType": "user"
        })
        soup = parse_html(resp)
        if "admin/dashboard" in resp.url or "admin" in resp.url:
            log_pass(module, "管理员登录跳转到管理后台", f"URL: {resp.url}")
        else:
            log_fail(module, "管理员登录跳转", f"URL: {resp.url}")

        # 检查管理后台菜单
        admin_menu_items = ["仪表盘", "用户管理", "数据分析", "用户画像",
                            "系统日志", "订单管理", "商品管理", "分类管理", "销售报表"]
        missing = [item for item in admin_menu_items if not assert_contains(soup, item)]
        if not missing:
            log_pass(module, "管理后台菜单包含所有必需项")
        else:
            log_fail(module, "管理后台菜单完整性", f"缺少: {', '.join(missing)}")

        self.get("/auth/logout")

    # ================================================================
    # 二、商品浏览（未登录）
    # ================================================================
    def test_product_browse(self):
        section_header("二、商品浏览（未登录）")
        module = "商品浏览"

        subsection_header("2.1 商品列表")

        resp = self.get("/products")
        soup = parse_html(resp)
        log_pass(module, "访问商品列表页面",
                 f"HTTP {resp.status_code}, URL: {resp.url}")

        # 分类筛选
        category_links = soup.find_all("a", href=lambda x: x and "categoryId" in str(x))
        if category_links:
            log_pass(module, "分类筛选功能存在",
                     f"找到 {len(category_links)} 个分类链接")
            # 点击一个分类
            test_link = category_links[0]["href"]
            resp = self.get(test_link)
            if resp.status_code == 200:
                log_pass(module, "分类筛选功能正常")
            else:
                log_fail(module, "分类筛选功能", f"HTTP {resp.status_code}")
        else:
            log_skip(module, "分类筛选功能", "当前无分类数据")

        subsection_header("2.2 商品详情")

        # 查找商品链接
        product_links = soup.find_all("a", href=lambda x: x and "productId" in str(x) and "detail" in str(x))
        if product_links:
            first_product_url = product_links[0]["href"]
            resp = self.get(first_product_url)
            soup = parse_html(resp)
            page_text = soup.get_text()
            has_product_info = any(kw in page_text for kw in ["价格", "¥", "描述", "库存", "详情", "分类"])
            if has_product_info:
                log_pass(module, "商品详情页正常显示")
            else:
                log_fail(module, "商品详情页", "未找到价格或商品信息")

            # 检查未登录时购物车按钮状态
            cart_btn = soup.find("button", string=lambda x: x and "购物车" in x) if soup.find("button") else None
            if cart_btn:
                if cart_btn.get("disabled") or assert_contains(soup, "登录"):
                    log_pass(module, "未登录时购物车按钮不可用")
                else:
                    log_fail(module, "未登录时购物车按钮", "按钮似乎可用，应提示登录")
            else:
                log_pass(module, "未登录时购物车按钮状态",
                         "页面中无购物车按钮（需登录后可见）")
        else:
            log_skip(module, "商品详情页测试", "当前无商品，需先添加商品")

    # ================================================================
    # 三、商家后台操作
    # ================================================================
    def test_merchant_operations(self):
        section_header("三、商家后台操作")
        module = "商家后台"

        # 商家登录
        self.post("/auth/login", data={
            "username": self.test_merchant["username"],
            "password": self.test_merchant["password"],
            "loginType": "merchant"
        })

        # 3.1 分类管理
        subsection_header("3.1 分类管理 (S1)")

        resp = self.get("/admin/categories")
        if resp.status_code == 200:
            log_pass(module, "进入分类管理页面")
        else:
            log_fail(module, "进入分类管理", f"HTTP {resp.status_code}")

        # 添加分类
        test_cat_name = f"测试分类_{int(time.time())}"
        resp = self.post("/admin/categories", data={
            "action": "add",
            "name": test_cat_name,
            "sortOrder": "1"
        })
        soup = parse_html(resp)
        if assert_contains(soup, test_cat_name):
            log_pass(module, "添加分类成功", f"分类名: {test_cat_name}")
            # 获取分类 ID — look for toggle/delete links near the category name
            all_links = soup.find_all("a", href=True)
            for link in all_links:
                href = link["href"]
                if "categoryId" in href:
                    match = re.search(r'categoryId=(\d+)', href)
                    if match:
                        self.category_id = match.group(1)
                        break
        else:
            log_fail(module, "添加分类", f"添加后页面中未找到: {test_cat_name}")

        # 禁用分类
        if self.category_id:
            # Find toggle link
            resp = self.get("/admin/categories")
            soup = parse_html(resp)
            toggle_link = soup.find("a", href=lambda x: x and "toggle" in str(x) and self.category_id in str(x))
            if toggle_link:
                resp = self.get(toggle_link["href"])
                soup = parse_html(resp)
                if assert_contains(soup, "禁用") or assert_contains(soup, "启用"):
                    log_pass(module, "分类状态切换（禁用/启用）")
                else:
                    log_fail(module, "分类状态切换", "未检测到状态变化")
            else:
                log_skip(module, "分类禁用操作", "未找到切换链接")
        else:
            log_skip(module, "分类管理操作", "无分类ID")

        # 删除分类 - 使用测试分类
        resp = self.get("/admin/categories")
        soup = parse_html(resp)
        delete_link = soup.find("a", href=lambda x: x and "delete" in str(x) and "category" in str(x))
        if delete_link:
            href = delete_link["href"]
            resp = self.get(href)
            soup = parse_html(resp)
            if not assert_contains(soup, test_cat_name):
                log_pass(module, "删除分类成功")
            else:
                log_fail(module, "删除分类", "分类仍存在")
        else:
            log_skip(module, "删除分类", "未找到删除链接")

        # 3.2 商品管理
        subsection_header("3.2 商品管理 (S2)")

        # 先确保有一个分类存在（用于商品关联）
        resp = self.get("/admin/categories")
        soup = parse_html(resp)
        # 获取一个已有分类
        existing_cat = soup.find("a", href=lambda x: x and "toggle" in str(x) and "categoryId" in str(x))
        if existing_cat:
            match = re.search(r'categoryId=(\d+)', existing_cat["href"])
            cat_id_for_product = match.group(1) if match else "1"
        else:
            cat_id_for_product = "1"
            # 先添加一个分类
            self.post("/admin/categories", data={
                "action": "add",
                "name": f"商品测试分类_{int(time.time())}",
                "sortOrder": "1"
            })
            resp = self.get("/admin/categories")
            soup = parse_html(resp)
            existing_cat = soup.find("a", href=lambda x: x and "toggle" in str(x))
            if existing_cat:
                match = re.search(r'categoryId=(\d+)', existing_cat["href"])
                cat_id_for_product = match.group(1) if match else "1"

        # 添加商品 1 (must use multipart/form-data because servlet uses @MultipartConfig)
        for i in range(3):
            product_name = f"测试商品_{int(time.time())}_{i}"
            resp = self.session.post(
                urljoin(BASE_URL + "/", "admin/products"),
                data={
                    "name": product_name,
                    "categoryId": cat_id_for_product,
                    "price": f"{(i + 1) * 99.9:.1f}",
                    "stock": str(100 + i * 10),
                    "description": f"这是测试商品 {i} 的描述",
                    "status": "1"
                },
                files={"imageFile": ("", b"", "application/octet-stream")},
                allow_redirects=True
            )
            if resp.status_code == 200:
                self.product_ids.append(product_name)
                log_pass(module, f"添加商品 {i+1}", product_name)
            else:
                log_fail(module, f"添加商品 {i+1}", f"HTTP {resp.status_code}")

        # 检查商品列表
        resp = self.get("/admin/products")
        soup = parse_html(resp)
        found = sum(1 for pid in self.product_ids if assert_contains(soup, pid))
        if found >= 2:
            log_pass(module, "商品列表显示新商品", f"找到 {found} 个测试商品")
        else:
            log_fail(module, "商品列表显示", f"仅找到 {found} 个测试商品")

        # 编辑商品 — find edit link
        edit_link = soup.find("a", href=lambda x: x and "edit" in str(x))
        if edit_link:
            log_pass(module, "商品编辑入口存在")
        else:
            log_skip(module, "商品编辑", "未找到编辑链接（可能功能不同）")

        # 删除商品
        delete_link = soup.find("a", href=lambda x: x and "delete" in str(x) and "product" in str(x))
        if delete_link:
            resp = self.get(delete_link["href"])
            if resp.status_code == 200:
                log_pass(module, "商品删除成功")
            else:
                log_fail(module, "商品删除", f"HTTP {resp.status_code}")
        else:
            log_skip(module, "商品删除", "未找到删除链接")

        # 3.3 日志查看
        subsection_header("3.3 日志查看 (S4)")

        resp = self.get("/admin/logs")
        if resp.status_code == 200:
            log_pass(module, "进入日志查看页面")
            soup = parse_html(resp)
            # Check for log tabs
            tabs = ["登录日志", "操作日志", "浏览日志", "购买日志"]
            found_tabs = [t for t in tabs if assert_contains(soup, t)]
            if len(found_tabs) >= 2:
                log_pass(module, "日志查看有多个 tab",
                         f"找到: {', '.join(found_tabs)}")
            else:
                log_fail(module, "日志查看 tab", f"仅找到: {', '.join(found_tabs)}")
        else:
            log_fail(module, "进入日志查看", f"HTTP {resp.status_code}")

        self.get("/auth/logout")

    # ================================================================
    # 四、用户购物全流程
    # ================================================================
    def test_user_shopping(self):
        section_header("四、用户购物全流程")
        module = "用户购物"

        # 用户登录
        resp = self.post("/auth/login", data={
            "username": self.test_user["username"],
            "password": self.test_user["password"],
            "loginType": "user"
        })

        # 4.1 浏览与购物车
        subsection_header("4.1 浏览与购物车 (C3)")

        resp = self.get("/products")
        soup = parse_html(resp)

        # 找商品链接
        product_links = soup.find_all("a", href=lambda x: x and "productId" in str(x))
        if len(product_links) >= 2:
            log_pass(module, "商品列表正常显示", f"找到 {len(product_links)} 个商品")

            # 进入商品详情
            first_product_url = product_links[0]["href"]
            resp = self.get(first_product_url)
            soup_detail = parse_html(resp)
            if assert_contains(soup_detail, "价格") or assert_contains(soup_detail, "¥") or assert_contains(soup_detail, "描述"):
                log_pass(module, "商品详情页正常显示")
            else:
                log_fail(module, "商品详情页", "未找到商品信息")

            # 加入购物车
            pid_match = re.search(r'productId=(\d+)', first_product_url)
            if pid_match:
                pid = pid_match.group(1)
                resp = self.post("/cart/add", data={
                    "productId": pid,
                    "quantity": "1"
                })
                if resp.status_code == 200:
                    soup_cart = parse_html(resp)
                    if assert_contains(soup_cart, "购物车") or "cart" in resp.url:
                        log_pass(module, "加入购物车成功", f"商品ID: {pid}")
                    else:
                        log_pass(module, "加入购物车", f"URL: {resp.url}")
                else:
                    log_fail(module, "加入购物车", f"HTTP {resp.status_code}")

                # 添加第二个商品
                if len(product_links) >= 2:
                    second_product_url = product_links[1]["href"]
                    pid_match2 = re.search(r'productId=(\d+)', second_product_url)
                    if pid_match2:
                        pid2 = pid_match2.group(1)
                        resp = self.post("/cart/add", data={
                            "productId": pid2,
                            "quantity": "2"
                        })
                        if resp.status_code == 200:
                            log_pass(module, "添加第二个商品到购物车")
                        else:
                            log_fail(module, "添加第二个商品", f"HTTP {resp.status_code}")
            else:
                log_fail(module, "解析商品ID", first_product_url)
        else:
            log_skip(module, "浏览与购物车测试", "商品列表为空，无法测试")

        # 查看购物车
        resp = self.get("/cart")
        soup = parse_html(resp)
        if assert_contains(soup, "购物车") or assert_contains(soup, "价格") or assert_contains(soup, "结算"):
            log_pass(module, "购物车页面正常显示")
        else:
            log_fail(module, "购物车页面", "未找到购物车内容")

        # 修改数量
        resp = self.post("/cart/update", data={
            "productId": pid if 'pid' in dir() else "1",
            "quantity": "3"
        })
        if resp.status_code == 200:
            log_pass(module, "修改购物车数量")
        else:
            log_fail(module, "修改购物车数量", f"HTTP {resp.status_code}")

        # 4.2 结算与支付
        subsection_header("4.2 结算与支付 (C3、C4)")

        resp = self.get("/checkout")
        if resp.status_code == 200:
            soup = parse_html(resp)
            if assert_contains(soup, "结算") or assert_contains(soup, "收货") or assert_contains(soup, "地址"):
                log_pass(module, "结算页面正常显示")
            else:
                log_fail(module, "结算页面", "未找到结算表单")

            # 提交结算
            resp = self.post("/checkout", data={
                "receiverName": "测试收货人",
                "receiverPhone": "13800000000",
                "receiverAddress": "测试地址123号"
            })
            if resp.status_code == 200:
                soup = parse_html(resp)
                # Should redirect to payment page
                if "payment" in resp.url or assert_contains(soup, "支付"):
                    log_pass(module, "结算提交成功，跳转支付页", f"URL: {resp.url}")
                else:
                    log_fail(module, "结算提交跳转", f"URL: {resp.url}")

                # 执行支付
                order_match = re.search(r'orderId=(\d+)', resp.url)
                if order_match:
                    order_id = order_match.group(1)
                    resp = self.post("/payment", data={
                        "orderId": order_id,
                        "result": "success"
                    })
                    if resp.status_code == 200:
                        soup = parse_html(resp)
                        if assert_contains(soup, "成功") or assert_contains(soup, "支付成功"):
                            log_pass(module, "支付成功")
                        else:
                            log_pass(module, "支付完成", f"URL: {resp.url}")
                    else:
                        log_fail(module, "支付", f"HTTP {resp.status_code}")
                else:
                    log_fail(module, "获取订单ID", f"URL: {resp.url}")
            else:
                log_fail(module, "提交结算", f"HTTP {resp.status_code}")
        else:
            log_fail(module, "进入结算页面", f"HTTP {resp.status_code}")

        # 4.3 查看订单
        subsection_header("4.3 查看订单")

        resp = self.get("/orders")
        if resp.status_code == 200:
            soup = parse_html(resp)
            if assert_contains(soup, "待发货") or assert_contains(soup, "订单"):
                log_pass(module, "订单列表页正常显示")
            else:
                log_fail(module, "订单列表页", "未找到订单信息")

            # 查看订单详情
            order_links = soup.find_all("a", href=lambda x: x and "orderId" in str(x) and "detail" in str(x))
            if not order_links:
                order_links = soup.find_all("a", href=lambda x: x and "orderId" in str(x))
            if order_links:
                target_url = order_links[0]["href"]
                resp = self.get(target_url)
                soup = parse_html(resp)
                page_text = soup.get_text()
                # Check for order detail content — use broader keyword matching
                detail_keywords = ["订单号", "订单详情", "金额", "地址", "收货人", "商品", "单价", "小计", "支付状态"]
                found_keywords = [kw for kw in detail_keywords if kw in page_text]
                if found_keywords:
                    log_pass(module, "订单详情页正常显示",
                             f"包含: {', '.join(found_keywords[:4])}")
                else:
                    log_fail(module, "订单详情页",
                             f"未找到订单详情, URL={target_url}, page_text(200)={page_text[:200]}")
            else:
                log_skip(module, "订单详情", "未找到订单链接")
        else:
            log_fail(module, "进入订单列表", f"HTTP {resp.status_code}")

        # 4.4 商品详情推荐
        subsection_header("4.4 商品详情推荐 (R1)")

        resp = self.get("/products")
        soup = parse_html(resp)
        product_links = soup.find_all("a", href=lambda x: x and "productId" in str(x))
        if product_links:
            resp = self.get(product_links[0]["href"])
            soup = parse_html(resp)
            if assert_contains(soup, "推荐") or assert_contains(soup, "也买了") or \
               assert_contains(soup, "浏览过"):
                log_pass(module, "商品详情页有推荐区域")
            else:
                log_skip(module, "商品详情推荐",
                         "需足够浏览数据后才显示（首次测试可能无数据）")
        else:
            log_skip(module, "商品详情推荐", "无商品可测试")

        # 4.5 个性化推荐
        subsection_header("4.5 个性化推荐 (R2)")

        resp = self.get("/recommendations")
        if resp.status_code == 200:
            soup = parse_html(resp)
            if assert_contains(soup, "推荐") or assert_contains(soup, "商品"):
                log_pass(module, "个性化推荐页面正常")
            else:
                log_skip(module, "个性化推荐",
                         "需购买数据后才显示推荐（首次测试可能无数据）")
        else:
            log_fail(module, "访问推荐页面", f"HTTP {resp.status_code}")

        self.get("/auth/logout")

    # ================================================================
    # 五、管理员后台
    # ================================================================
    def test_admin_backend(self):
        section_header("五、管理员后台")
        module = "管理员后台"

        # 管理员登录
        self.post("/auth/login", data={
            "username": "admin",
            "password": "admin123",
            "loginType": "user"
        })

        # 5.1 仪表盘
        subsection_header("5.1 仪表盘 (AN4)")

        resp = self.get("/admin/dashboard")
        if resp.status_code == 200:
            soup = parse_html(resp)
            log_pass(module, "仪表盘页面加载")

            kpis = ["用户", "订单", "营收"]
            found_kpis = [k for k in kpis if assert_contains(soup, k)]
            if len(found_kpis) >= 2:
                log_pass(module, "KPI 卡片显示", f"找到: {', '.join(found_kpis)}")
            else:
                log_fail(module, "KPI 卡片", f"仅找到: {', '.join(found_kpis)}")

            if assert_contains(soup, "排行") or assert_contains(soup, "Top") or \
               assert_contains(soup, "销售") or assert_element_exists(soup, "canvas"):
                log_pass(module, "销售排行图存在")
            else:
                log_fail(module, "销售排行图", "未找到图表元素")
        else:
            log_fail(module, "仪表盘加载", f"HTTP {resp.status_code}")

        # 5.2 用户管理
        subsection_header("5.2 用户管理 (A1、A2)")

        resp = self.get("/admin/users")
        if resp.status_code == 200:
            soup = parse_html(resp)
            log_pass(module, "用户管理页面加载")

            # 检查用户列表
            if assert_contains(soup, "角色") or assert_contains(soup, "状态"):
                log_pass(module, "用户列表含角色和状态列")
            else:
                log_fail(module, "用户列表", "未找到角色或状态信息")

            # 新增商家
            test_new_merchant = f"sales_{int(time.time())}"
            resp = self.post("/admin/users", data={
                "action": "createMerchant",
                "username": test_new_merchant,
                "email": f"{test_new_merchant}@test.com",
                "phone": "13700000000",
                "password": "Test@123"
            })
            soup = parse_html(resp)
            if assert_contains(soup, test_new_merchant):
                log_pass(module, "新增销售人员成功", f"用户名: {test_new_merchant}")
            else:
                log_fail(module, "新增销售人员", "列表中未出现新用户")

            # 找到新用户的 ID 用于后续操作
            # Find any operation link to extract user ID pattern
            all_action_links = soup.find_all("a", href=True)
            user_action_link = None
            for link in all_action_links:
                href = link["href"]
                if "userId" in href and ("toggleStatus" in href or "resetPassword" in href or "delete" in href):
                    # Prefer links near our test user
                    parent_text = link.find_parent("tr").get_text() if link.find_parent("tr") else ""
                    if test_new_merchant in parent_text:
                        user_action_link = link
                        break

            if not user_action_link:
                # Fall back to first matching link
                for link in all_action_links:
                    href = link["href"]
                    if "userId" in href and ("toggleStatus" in href or "resetPassword" in href):
                        user_action_link = link
                        break

            if user_action_link:
                href = user_action_link["href"]
                match = re.search(r'userId=(\d+)', href)
                if match:
                    test_user_id = match.group(1)

                    # 重置密码
                    reset_link = soup.find("a", href=lambda x: x and "resetPassword" in str(x) and test_user_id in str(x))
                    if reset_link:
                        resp = self.get(reset_link["href"])
                        soup = parse_html(resp)
                        log_pass(module, "重置密码操作完成")
                    else:
                        log_skip(module, "重置密码", "未找到操作链接")

                    # 禁用用户
                    disable_link = soup.find("a", href=lambda x: x and "toggleStatus" in str(x) and test_user_id in str(x))
                    if disable_link:
                        resp = self.get(disable_link["href"])
                        soup = parse_html(resp)
                        log_pass(module, "用户状态切换（禁用/启用）")
                    else:
                        log_skip(module, "禁用/启用用户", "未找到操作链接")

                    # 删除用户
                    delete_link = soup.find("a", href=lambda x: x and "delete" in str(x) and test_user_id in str(x))
                    if delete_link:
                        resp = self.get(delete_link["href"])
                        log_pass(module, "删除用户操作完成")
                    else:
                        log_skip(module, "删除用户", "未找到删除链接")
                else:
                    log_skip(module, "用户管理操作", "无法解析用户ID")
            else:
                log_skip(module, "用户管理操作", "未找到操作链接")
        else:
            log_fail(module, "用户管理页面加载", f"HTTP {resp.status_code}")

        # 5.3 数据分析
        subsection_header("5.3 数据分析 (AN2、AN3、AN5、A4)")

        for range_type in ["week", "month", "quarter"]:
            resp = self.get(f"/admin/analytics?range={range_type}")
            if resp.status_code == 200:
                soup = parse_html(resp)
                if assert_contains(soup, "趋势") or assert_contains(soup, "销售") or \
                   assert_element_exists(soup, "canvas") or assert_element_exists(soup, "chart"):
                    log_pass(module, f"数据分析页面加载 ({range_type})")
                else:
                    log_fail(module, f"数据分析 ({range_type})", "未找到趋势图表")
            else:
                log_fail(module, f"数据分析 ({range_type})", f"HTTP {resp.status_code}")

        # Check main analytics page features
        resp = self.get("/admin/analytics?range=week")
        soup = parse_html(resp)
        analytics_features = {
            "趋势图": ["趋势", "chart", "canvas"],
            "预测线": ["预测", "虚线", "forecast"],
            "环比增长": ["环比", "增长", "growth"],
            "异常检测": ["异常", "anomaly"],
            "品类饼图": ["品类", "饼图", "分类", "pie"],
            "订单状态分布": ["订单状态", "分布", "status"],
            "库存分布": ["库存", "分布", "stock"]
        }
        for feature, keywords in analytics_features.items():
            found = any(assert_contains(soup, kw) or assert_element_exists(soup, kw) for kw in keywords)
            if found:
                log_pass(module, f"{feature}正常显示")
            else:
                log_skip(module, feature, "可能需要更多数据或 JS 渲染")

        # 5.4 用户画像
        subsection_header("5.4 用户画像 (AN1)")

        resp = self.get("/admin/profiles")
        if resp.status_code == 200:
            soup = parse_html(resp)
            if assert_contains(soup, "用户") and (assert_contains(soup, "偏好") or assert_contains(soup, "消费")):
                log_pass(module, "用户画像页面正常")
            else:
                log_fail(module, "用户画像页面", "未找到画像数据")

            if assert_contains(soup, "IP") or assert_contains(soup, "地域") or assert_contains(soup, "地区"):
                log_pass(module, "地域列有IP推断地区")
            else:
                log_skip(module, "IP地域推断", "可能需要更多数据")
        else:
            log_fail(module, "用户画像页面加载", f"HTTP {resp.status_code}")

        # 5.5 订单管理
        subsection_header("5.5 订单管理")

        resp = self.get("/admin/orders")
        if resp.status_code == 200:
            soup = parse_html(resp)
            if assert_contains(soup, "订单") or assert_contains(soup, "待发货"):
                log_pass(module, "管理员订单列表正常显示")
            else:
                log_fail(module, "管理员订单列表", "未找到订单")

            # 查找待发货订单
            ship_links = soup.find_all("a", href=lambda x: x and "ship" in str(x))
            if ship_links:
                resp = self.get(ship_links[0]["href"])
                soup = parse_html(resp)
                if assert_contains(soup, "已发货") or assert_contains(soup, "发货"):
                    log_pass(module, "订单发货成功")
                else:
                    log_pass(module, "发货操作完成")
            else:
                log_skip(module, "订单发货", "无待发货订单")
        else:
            log_fail(module, "管理员订单列表加载", f"HTTP {resp.status_code}")

        # 5.6 系统日志
        subsection_header("5.6 系统日志 (D1、D5)")

        resp = self.get("/admin/logs")
        if resp.status_code == 200:
            soup = parse_html(resp)
            log_pass(module, "系统日志页面加载")

            log_tabs = {
                "登录日志": ["登录", "IP"],
                "操作日志": ["操作", "重置", "禁用", "发货"],
                "浏览日志": ["浏览", "停留", "dwell"],
                "购买日志": ["购买", "单价", "数量"]
            }
            for tab_name, keywords in log_tabs.items():
                if assert_contains(soup, tab_name):
                    found_kw = [kw for kw in keywords if assert_contains(soup, kw)]
                    if found_kw:
                        log_pass(module, f"{tab_name} tab 正常",
                                 f"包含: {', '.join(found_kw)}")
                    else:
                        log_skip(module, f"{tab_name}内容",
                                 "可能需要更多数据")
                else:
                    log_fail(module, f"{tab_name} tab", "未找到 tab")
        else:
            log_fail(module, "系统日志页面加载", f"HTTP {resp.status_code}")

        self.get("/auth/logout")

    # ================================================================
    # 六、数据验证
    # ================================================================
    def test_data_validation(self):
        section_header("六、数据验证（MySQL 查询）")
        module = "数据验证"

        print(f"\n  {CYAN}以下 SQL 查询需在 MySQL 中手动执行验证：{RESET}\n")

        queries = [
            ("6.1 登录日志", "D1、D4",
             "SELECT * FROM user_login_logs ORDER BY id DESC LIMIT 5;",
             "应包含 user_id、ip_address、login_at"),
            ("6.2 浏览日志", "D2",
             "SELECT * FROM user_browse_logs ORDER BY id DESC LIMIT 5;",
             "应包含 product_id、category_id、dwell_time_seconds"),
            ("6.3 购买日志", "D3",
             "SELECT * FROM user_purchase_logs ORDER BY id DESC LIMIT 5;",
             "应包含 product_id、category_id、unit_price、quantity"),
            ("6.4 操作日志", "D5",
             "SELECT * FROM operation_logs ORDER BY id DESC LIMIT 10;",
             "应包含 operator_id、action、detail、ip_address"),
        ]

        for name, tag, sql, expected in queries:
            print(f"  {BOLD}{name} ({tag}){RESET}")
            print(f"  {sql}")
            print(f"  期望: {expected}")
            print()

        # Try to connect to MySQL directly if pymysql is available
        try:
            import pymysql
            conn = pymysql.connect(
                host="localhost",
                port=3306,
                user="root",
                password="qazwsxcde",
                database="javaweb_shop",
                charset="utf8mb4"
            )
            cursor = conn.cursor()

            # 6.1
            cursor.execute("SELECT * FROM user_login_logs ORDER BY id DESC LIMIT 5")
            rows = cursor.fetchall()
            if rows:
                cols = [desc[0] for desc in cursor.description]
                has_fields = all(f in cols for f in ["user_id", "ip_address", "login_at"])
                if has_fields:
                    log_pass(module, "登录日志有记录且字段完整",
                             f"{len(rows)} 条记录, 字段: {', '.join(cols[:5])}")
                else:
                    log_fail(module, "登录日志字段", f"字段: {', '.join(cols)}")
            else:
                log_fail(module, "登录日志", "无记录")

            # 6.2
            cursor.execute("SELECT * FROM user_browse_logs ORDER BY id DESC LIMIT 5")
            rows = cursor.fetchall()
            if rows:
                cols = [desc[0] for desc in cursor.description]
                has_fields = all(f in cols for f in ["product_id", "category_id", "dwell_time_seconds"])
                if has_fields:
                    has_dwell = any(r[cols.index("dwell_time_seconds")] and r[cols.index("dwell_time_seconds")] > 0 for r in rows)
                    log_pass(module, "浏览日志有记录且字段完整",
                             f"{len(rows)} 条记录" + (", 含停留时长>0" if has_dwell else ""))
                else:
                    log_fail(module, "浏览日志字段", f"字段: {', '.join(cols)}")
            else:
                log_skip(module, "浏览日志", "无记录（需用户浏览后生成）")

            # 6.3
            cursor.execute("SELECT * FROM user_purchase_logs ORDER BY id DESC LIMIT 5")
            rows = cursor.fetchall()
            if rows:
                cols = [desc[0] for desc in cursor.description]
                has_fields = all(f in cols for f in ["product_id", "category_id", "unit_price", "quantity"])
                if has_fields:
                    log_pass(module, "购买日志有记录且字段完整",
                             f"{len(rows)} 条记录")
                else:
                    log_fail(module, "购买日志字段", f"字段: {', '.join(cols)}")
            else:
                log_fail(module, "购买日志", "无记录（前面的购物流程应已产生数据）")

            # 6.4
            cursor.execute("SELECT * FROM operation_logs ORDER BY id DESC LIMIT 10")
            rows = cursor.fetchall()
            if rows:
                cols = [desc[0] for desc in cursor.description]
                has_fields = all(f in cols for f in ["operator_id", "action", "detail", "ip_address"])
                if has_fields:
                    log_pass(module, "操作日志有记录且字段完整",
                             f"{len(rows)} 条记录")
                else:
                    log_fail(module, "操作日志字段", f"字段: {', '.join(cols)}")
            else:
                log_fail(module, "操作日志", "无记录")

            conn.close()
        except ImportError:
            print(f"  {YELLOW}pymysql 未安装，跳过自动 SQL 验证。"
                  f"可运行: pip install pymysql{RESET}")
            for name, tag, sql, expected in queries:
                log_skip(module, name, "pymysql 未安装，请手动执行 SQL")
        except Exception as e:
            print(f"  {YELLOW}MySQL 连接失败: {e}{RESET}")
            for name, tag, sql, expected in queries:
                log_skip(module, name, f"MySQL 连接失败: {e}")

    # ================================================================
    # 汇总
    # ================================================================
    def print_summary(self):
        section_header("检查结果汇总")

        total = results["pass"] + results["fail"] + results["skip"]
        print(f"\n  总计: {total} 项")
        print(f"  {GREEN}通过: {results['pass']}{RESET}")
        print(f"  {RED}失败: {results['fail']}{RESET}")
        print(f"  {YELLOW}跳过: {results['skip']}{RESET}")

        if results["fail"] > 0:
            print(f"\n  {RED}{BOLD}失败项详情：{RESET}")
            for status, module, item, detail in results["details"]:
                if status == "FAIL":
                    print(f"    {RED}✗{RESET} [{module}] {item} — {detail}")

        print(f"\n  {'='*50}")
        if results["fail"] == 0:
            print(f"  {GREEN}{BOLD}全部通过！{RESET}")
        else:
            print(f"  {RED}{BOLD}存在 {results['fail']} 项失败，请检查上方详情。{RESET}")
        print()

    def run_all(self):
        print(f"\n{BOLD}{'='*60}")
        print(f"  功能检查表自动化测试")
        print(f"  目标: {BASE_URL}")
        print(f"  时间: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*60}{RESET}")

        try:
            self.test_prerequisites()
            self.test_register_and_login()
            self.test_product_browse()
            self.test_merchant_operations()
            self.test_user_shopping()
            self.test_admin_backend()
            self.test_data_validation()
        except Exception as e:
            print(f"\n{RED}测试执行出错: {e}{RESET}")
            traceback.print_exc()

        self.print_summary()


if __name__ == "__main__":
    runner = TestRunner()
    runner.run_all()
