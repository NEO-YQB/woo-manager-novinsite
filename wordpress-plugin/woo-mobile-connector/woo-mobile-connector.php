<?php
/**
 * Plugin Name: مدیریت فروشگاه نوین سایت
 * Plugin URI: https://novinsite.com
 * Description: اتصال امن، سریع و اختصاصی فروشگاه ووکامرس به اپلیکیشن موبایل نوین سایت با اسکن کد QR و ارائه وب‌سرویس‌های بهینه‌سازی شده داشبورد و رویدادهای سفارش.
 * Version: 1.0.0
 * Author: نوین سایت
 * Author URI: https://novinsite.com
 * Text Domain: woo-mobile-connector
 * Domain Path: /languages
 * Requires at least: 5.8
 * Requires PHP: 7.4
 * WC requires at least: 5.0
 * WC tested up to: 9.0
 */

if (!defined('ABSPATH')) {
    exit; // خروج در صورت دسترسی مستقیم
}

class WooMobileAppConnector {

    private static $instance = null;
    const VERSION = '1.0.0';
    const API_NAMESPACE = 'woo-app/v1';

    public static function get_instance() {
        if (null === self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    private function __construct() {
        // بررسی فعال بودن ووکامرس
        add_action('plugins_loaded', array($this, 'check_woocommerce'));
        // افزودن منوی مدیریت
        add_action('admin_menu', array($this, 'register_admin_menu'));
        // ثبت اندپوینت‌های REST API
        add_action('rest_api_init', array($this, 'register_rest_routes'));
        // پاکسازی کش آمار هنگام تغییر وضعیت سفارش
        add_action('woocommerce_order_status_changed', array($this, 'clear_dashboard_cache'));
        // ثبت رویداد سفارشات برای سیستم اعلان‌ها
        add_action('woocommerce_new_order', array($this, 'log_order_event'), 10, 1);
        add_action('woocommerce_order_status_processing', array($this, 'log_order_event'), 10, 1);
        add_action('woocommerce_order_status_completed', array($this, 'log_order_event'), 10, 1);
        // اکشن‌های ایجکس برای ساخت کلیدهای اتصال
        add_action('wp_ajax_wmac_generate_keys', array($this, 'ajax_generate_keys'));
    }

    public function check_woocommerce() {
        if (!class_exists('WooCommerce')) {
            add_action('admin_notices', function() {
                echo '<div class="error"><p><strong>پلاگین Woo Mobile App Connector:</strong> برای کارکرد این افزونه، افزونه ووکامرس باید فعال باشد.</p></div>';
            });
        }
    }

    public function register_admin_menu() {
        add_menu_page(
            'مدیریت فروشگاه نوین سایت',
            '📱 فروشگاه نوین سایت',
            'manage_woocommerce',
            'woo-mobile-app',
            array($this, 'render_admin_page'),
            'dashicons-smartphone',
            56
        );
    }

    public function register_rest_routes() {
        // اندپوینت تجمیعی آمار داشبورد
        register_rest_route(self::API_NAMESPACE, '/dashboard-summary', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_dashboard_summary'),
            'permission_callback' => array($this, 'check_api_permission'),
        ));

        // اندپوینت اعتبارسنجی اتصال
        register_rest_route(self::API_NAMESPACE, '/verify-connection', array(
            'methods' => 'GET',
            'callback' => array($this, 'verify_connection'),
            'permission_callback' => array($this, 'check_api_permission'),
        ));

        // اندپوینت لیست اعلان‌های اخیر سفارشات
        register_rest_route(self::API_NAMESPACE, '/recent-notifications', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_recent_notifications'),
            'permission_callback' => array($this, 'check_api_permission'),
        ));
    }

    public function check_api_permission($request) {
        // بررسی احراز هویت با ووکامرس یا توکن کاربر
        if (current_user_can('manage_woocommerce')) {
            return true;
        }

        // بررسی دسترسی Basic Auth ووکامرس
        $user_id = apply_filters('woocommerce_rest_check_permissions', null, 'read');
        if (!empty($user_id) && user_can($user_id, 'manage_woocommerce')) {
            return true;
        }

        // بررسی از طریق هدر توکن اختصاصی در صورت ست شدن
        $token = $request->get_header('x-woo-app-token');
        $stored_token = get_option('wmac_app_token', '');
        if (!empty($token) && !empty($stored_token) && hash_equals($stored_token, $token)) {
            return true;
        }

        return new WP_Error(
            'rest_forbidden',
            'شما اجازه دسترسی به این بخش را ندارید. لطفاً از کلیدهای معتبر مدیر فروشگاه استفاده کنید.',
            array('status' => 403)
        );
    }

    public function verify_connection($request) {
        return rest_ensure_response(array(
            'success' => true,
            'message' => 'اتصال با موفقیت برقرار شد.',
            'store_name' => get_bloginfo('name'),
            'store_url' => get_site_url(),
            'currency' => get_woocommerce_currency(),
            'currency_symbol' => html_entity_decode(get_woocommerce_currency_symbol()),
            'wc_version' => WC()->version,
            'plugin_version' => self::VERSION,
        ));
    }

    public function log_order_event($order_id) {
        $order = wc_get_order($order_id);
        if (!$order) return;

        $events = get_option('wmac_recent_order_notifications', array());
        if (!is_array($events)) $events = array();

        $event = array(
            'id' => 'wp_' . $order_id . '_' . time(),
            'order_id' => $order_id,
            'order_number' => $order->get_order_number(),
            'customer_name' => trim($order->get_formatted_billing_full_name()),
            'total' => (float) $order->get_total(),
            'currency_symbol' => html_entity_decode(get_woocommerce_currency_symbol($order->get_currency())),
            'status' => $order->get_status(),
            'timestamp' => current_time('mysql'),
        );

        array_unshift($events, $event);
        $events = array_slice($events, 0, 20);
        update_option('wmac_recent_order_notifications', $events);
        $this->clear_dashboard_cache();
    }

    public function get_recent_notifications($request) {
        $events = get_option('wmac_recent_order_notifications', array());
        return rest_ensure_response(array(
            'success' => true,
            'notifications' => is_array($events) ? $events : array(),
        ));
    }

    public function get_dashboard_summary($request) {
        $cache_key = 'wmac_dashboard_summary_cache';
        $cached_data = get_transient($cache_key);

        if (false !== $cached_data && empty($request->get_param('force_refresh'))) {
            return rest_ensure_response($cached_data);
        }

        // محاسبه آمار امروز
        $today_start = date('Y-m-d 00:00:00', current_time('timestamp'));
        $today_end = date('Y-m-d 23:59:59', current_time('timestamp'));

        // سفارشات بر اساس وضعیت
        $order_statuses = wc_get_order_statuses();
        $status_counts = array();
        foreach (array_keys($order_statuses) as $status_key) {
            $clean_status = str_replace('wc-', '', $status_key);
            $status_counts[$clean_status] = wc_orders_count($clean_status);
        }

        // محاسبه فروش امروز
        $orders_today = wc_get_orders(array(
            'date_created' => $today_start . '...' . $today_end,
            'status' => array('wc-completed', 'wc-processing', 'wc-on-hold'),
            'limit' => -1,
            'return' => 'ids',
        ));

        $revenue_today = 0;
        foreach ($orders_today as $order_id) {
            $order = wc_get_order($order_id);
            if ($order) {
                $revenue_today += (float) $order->get_total();
            }
        }

        // سفارشات ماه جاری
        $month_start = date('Y-m-01 00:00:00', current_time('timestamp'));
        $orders_month = wc_get_orders(array(
            'date_created' => $month_start . '...' . $today_end,
            'status' => array('wc-completed', 'wc-processing', 'wc-on-hold'),
            'limit' => -1,
            'return' => 'ids',
        ));

        $revenue_month = 0;
        foreach ($orders_month as $order_id) {
            $order = wc_get_order($order_id);
            if ($order) {
                $revenue_month += (float) $order->get_total();
            }
        }

        // محصولات کم‌موجودی یا ناموجود
        $low_stock_count = 0;
        $out_of_stock_count = 0;
        if (function_exists('wc_get_products')) {
            $low_stock_amount = get_option('woocommerce_notify_low_stock_amount', 2);
            $low_stock_products = wc_get_products(array(
                'stock_status' => 'instock',
                'manage_stock' => true,
                'limit' => -1,
                'return' => 'ids',
            ));
            foreach ($low_stock_products as $pid) {
                $product = wc_get_product($pid);
                if ($product && $product->managing_stock() && $product->get_stock_quantity() <= $low_stock_amount) {
                    $low_stock_count++;
                }
            }

            $out_of_stock_products = wc_get_products(array(
                'stock_status' => 'outofstock',
                'limit' => -1,
                'return' => 'ids',
            ));
            $out_of_stock_count = count($out_of_stock_products);
        }

        // آخرین ۵ سفارش با جزییات بهینه
        $recent_orders_query = wc_get_orders(array(
            'limit' => 6,
            'orderby' => 'date',
            'order' => 'DESC',
        ));

        $recent_orders = array();
        foreach ($recent_orders_query as $order) {
            $recent_orders[] = array(
                'id' => $order->get_id(),
                'order_number' => $order->get_order_number(),
                'status' => $order->get_status(),
                'total' => (float) $order->get_total(),
                'currency' => $order->get_currency(),
                'currency_symbol' => html_entity_decode(get_woocommerce_currency_symbol($order->get_currency())),
                'date_created' => $order->get_date_created() ? $order->get_date_created()->date('Y-m-d H:i:s') : '',
                'customer_name' => trim($order->get_formatted_billing_full_name()),
                'customer_phone' => $order->get_billing_phone(),
                'items_count' => $order->get_item_count(),
            );
        }

        // محاسبه دقیق آمار ۷ روز گذشته برای نمودار هفتگی
        $weekly_sales = array();
        $persian_day_names = array(
            'Sat' => 'ش',
            'Sun' => 'ی',
            'Mon' => 'د',
            'Tue' => 'س',
            'Wed' => 'چ',
            'Thu' => 'پ',
            'Fri' => 'ج',
        );

        for ($i = 6; $i >= 0; $i--) {
            $timestamp = strtotime("-$i days", current_time('timestamp'));
            $d_start = date('Y-m-d 00:00:00', $timestamp);
            $d_end = date('Y-m-d 23:59:59', $timestamp);
            $en_day = date('D', $timestamp);
            $day_label = isset($persian_day_names[$en_day]) ? $persian_day_names[$en_day] : $en_day;

            $day_order_ids = wc_get_orders(array(
                'date_created' => $d_start . '...' . $d_end,
                'status' => array('wc-completed', 'wc-processing', 'wc-on-hold'),
                'limit' => -1,
                'return' => 'ids',
            ));

            $day_revenue = 0;
            foreach ($day_order_ids as $oid) {
                $o = wc_get_order($oid);
                if ($o) {
                    $day_revenue += (float) $o->get_total();
                }
            }

            $weekly_sales[] = array(
                'day' => $day_label,
                'date' => date('Y-m-d', $timestamp),
                'revenue' => $day_revenue,
                'orders_count' => count($day_order_ids),
            );
        }

        $response_data = array(
            'success' => true,
            'timestamp' => current_time('mysql'),
            'store' => array(
                'name' => get_bloginfo('name'),
                'url' => get_site_url(),
                'currency' => get_woocommerce_currency(),
                'currency_symbol' => html_entity_decode(get_woocommerce_currency_symbol()),
                'currency_position' => get_option('woocommerce_currency_pos', 'right'),
                'price_thousand_sep' => get_option('woocommerce_price_thousand_sep', ','),
                'price_decimal_sep' => get_option('woocommerce_price_decimal_sep', '.'),
                'price_num_decimals' => absint(get_option('woocommerce_price_num_decimals', 0)),
            ),
            'kpis' => array(
                'today_sales' => $revenue_today,
                'today_orders_count' => count($orders_today),
                'month_sales' => $revenue_month,
                'month_orders_count' => count($orders_month),
                'pending_orders' => isset($status_counts['pending']) ? $status_counts['pending'] : 0,
                'processing_orders' => isset($status_counts['processing']) ? $status_counts['processing'] : 0,
                'on_hold_orders' => isset($status_counts['on-hold']) ? $status_counts['on-hold'] : 0,
                'completed_orders' => isset($status_counts['completed']) ? $status_counts['completed'] : 0,
                'low_stock_count' => $low_stock_count,
                'out_of_stock_count' => $out_of_stock_count,
            ),
            'order_statuses' => $status_counts,
            'recent_orders' => $recent_orders,
            'weekly_sales' => $weekly_sales,
        );

        // کش به مدت ۶۰ ثانیه جهت بهبود چشمگیر کارایی
        set_transient($cache_key, $response_data, 60);

        return rest_ensure_response($response_data);
    }

    public function clear_dashboard_cache() {
        delete_transient('wmac_dashboard_summary_cache');
    }

    public function ajax_generate_keys() {
        check_ajax_referer('wmac_nonce', 'nonce');

        if (!current_user_can('manage_woocommerce')) {
            wp_send_json_error(array('message' => 'دسترسی غیرمجاز.'));
        }

        global $wpdb;

        $user_id = get_current_user_id();
        $description = 'WooCommerce Mobile App - ' . current_time('Y-m-d H:i');
        $consumer_key = 'ck_' . wc_rand_hash();
        $consumer_secret = 'cs_' . wc_rand_hash();

        $result = $wpdb->insert(
            $wpdb->prefix . 'woocommerce_api_keys',
            array(
                'user_id' => $user_id,
                'description' => $description,
                'permissions' => 'read_write',
                'consumer_key' => wc_api_hash($consumer_key),
                'consumer_secret' => $consumer_secret,
                'truncated_key' => substr($consumer_key, -7),
                'last_access' => null,
            ),
            array('%d', '%s', '%s', '%s', '%s', '%s', '%s')
        );

        if (false === $result) {
            wp_send_json_error(array('message' => 'خطا در ثبت کلید API در دیتابیس.'));
        }

        // ساخت داده‌های جفت‌سازی برای QR کد
        $qr_payload = array(
            'version' => 1,
            'site_url' => get_site_url(),
            'site_name' => get_bloginfo('name'),
            'consumer_key' => $consumer_key,
            'consumer_secret' => $consumer_secret,
            'currency' => get_woocommerce_currency(),
            'created_at' => current_time('timestamp'),
        );

        wp_send_json_success(array(
            'qr_payload' => base64_encode(json_encode($qr_payload)),
            'consumer_key' => $consumer_key,
            'consumer_secret' => $consumer_secret,
            'site_url' => get_site_url(),
        ));
    }

    public function render_admin_page() {
        if (!current_user_can('manage_woocommerce')) {
            wp_die('شما دسترسی لازم برای این صفحه را ندارید.');
        }

        // ساخت نانس برای امنیت ایجکس
        $nonce = wp_create_nonce('wmac_nonce');
        $site_url = get_site_url();
        $site_name = get_bloginfo('name');
        $logo_url = plugins_url('assets/logo.png', __FILE__);
        ?>
        <div class="wrap" style="font-family: inherit; direction: rtl;">
            <div style="background: linear-gradient(135deg, #10b981 0%, #047857 100%); color: #fff; padding: 25px 30px; border-radius: 14px; margin-top: 20px; box-shadow: 0 10px 25px rgba(16, 185, 129, 0.25);">
                <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 15px;">
                    <div style="display: flex; align-items: center; gap: 16px;">
                        <img src="<?php echo esc_url($logo_url); ?>" alt="لوگو نوین سایت" style="width: 58px; height: 58px; background: #fff; padding: 6px; border-radius: 14px; box-shadow: 0 4px 12px rgba(0,0,0,0.12); object-fit: contain;">
                        <div>
                            <h1 style="color: #fff; margin: 0 0 6px 0; font-size: 24px; font-weight: 700;">📱 مدیریت فروشگاه نوین سایت</h1>
                            <p style="margin: 0; color: #ecfdf5; font-size: 14px;">با اسکن کد QR زیر در اپلیکیشن موبایل، فروشگاه شما در چند ثانیه به صورت کاملاً امن متصل خواهد شد.</p>
                        </div>
                    </div>
                    <span style="background: rgba(255, 255, 255, 0.2); padding: 8px 16px; border-radius: 30px; font-size: 13px; font-weight: 600;">نسخه <?php echo esc_html(self::VERSION); ?></span>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 25px; margin-top: 25px;">
                <!-- کارت اتصال با کد QR -->
                <div style="background: #fff; border-radius: 14px; padding: 30px; border: 1px solid #e2e8f0; box-shadow: 0 4px 12px rgba(0,0,0,0.03);">
                    <h2 style="font-size: 18px; color: #1e293b; margin-top: 0; display: flex; align-items: center; gap: 8px;">
                        <span>📷</span> گام اول: اسکن کد QR اختصاصی
                    </h2>
                    <p style="color: #64748b; font-size: 14px; line-height: 1.8;">
                        در اپلیکیشن موبایل روی دکمه <strong>«اسکن کد QR»</strong> تپ کنید و دوربین را مقابل این کد قرار دهید. کلیدهای دسترسی امن خودکار ایجاد و بارگذاری می‌شوند.
                    </p>

                    <div style="text-align: center; margin: 30px 0; padding: 25px; background: #f8fafc; border-radius: 12px; border: 2px dashed #cbd5e1;">
                        <div id="qr-container" style="display: inline-block; background: #fff; padding: 15px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); min-width: 200px; min-height: 200px;">
                            <div id="qr-loading" style="padding-top: 80px; color: #94a3b8;">در حال تولید کد QR اختصاصی...</div>
                            <div id="qrcode" style="display: none;"></div>
                        </div>
                        <div style="margin-top: 15px;">
                            <button id="btn-refresh-qr" class="button button-secondary" style="height: 38px; border-radius: 8px; font-weight: 600;">
                                🔄 بازتولید کلید و کد QR جدید
                            </button>
                        </div>
                    </div>

                    <div id="credentials-box" style="display: none; background: #f1f5f9; padding: 15px; border-radius: 8px; font-family: monospace; direction: ltr; text-align: left; font-size: 13px;">
                        <div style="margin-bottom: 6px;"><strong>Site URL:</strong> <span id="cred-url"></span></div>
                        <div style="margin-bottom: 6px;"><strong>Consumer Key:</strong> <span id="cred-key"></span></div>
                        <div><strong>Consumer Secret:</strong> <span id="cred-secret">••••••••••••••••</span></div>
                    </div>
                </div>

                <!-- کارت راهنما و اتصال دستی -->
                <div style="background: #fff; border-radius: 14px; padding: 30px; border: 1px solid #e2e8f0; box-shadow: 0 4px 12px rgba(0,0,0,0.03);">
                    <h2 style="font-size: 18px; color: #1e293b; margin-top: 0; display: flex; align-items: center; gap: 8px;">
                        <span>🔑</span> روش دوم: اتصال دستی با کلیدهای API
                    </h2>
                    <p style="color: #64748b; font-size: 14px; line-height: 1.8;">
                        در صورتی که نمی‌خواهید از دوربین یا QR کد استفاده کنید، می‌توانید از طریق صفحه <strong>ووکامرس > پیکربندی > پیشرفته > REST API</strong> یک کلید با دسترسی «خواندن/نوشتن» بسازید و مقادیر زیر را در اپلیکیشن وارد کنید:
                    </p>

                    <div style="background: #f8fafc; border-radius: 10px; padding: 20px; margin: 20px 0; border: 1px solid #e2e8f0;">
                        <div style="margin-bottom: 12px;">
                            <label style="display: block; font-weight: 600; color: #334155; margin-bottom: 4px;">آدرس فروشگاه (Site URL):</label>
                            <input type="text" readonly value="<?php echo esc_url($site_url); ?>" style="width: 100%; direction: ltr; font-family: monospace; background: #fff; border: 1px solid #cbd5e1; border-radius: 6px; padding: 8px;" onclick="this.select();">
                        </div>
                        <div style="margin-bottom: 12px;">
                            <label style="display: block; font-weight: 600; color: #334155; margin-bottom: 4px;">کلید مصرف‌کننده (Consumer Key):</label>
                            <input type="text" id="manual-key" readonly value="در حال ساخت..." style="width: 100%; direction: ltr; font-family: monospace; background: #fff; border: 1px solid #cbd5e1; border-radius: 6px; padding: 8px;" onclick="this.select();">
                        </div>
                        <div>
                            <label style="display: block; font-weight: 600; color: #334155; margin-bottom: 4px;">رمز مصرف‌کننده (Consumer Secret):</label>
                            <input type="text" id="manual-secret" readonly value="در حال ساخت..." style="width: 100%; direction: ltr; font-family: monospace; background: #fff; border: 1px solid #cbd5e1; border-radius: 6px; padding: 8px;" onclick="this.select();">
                        </div>
                    </div>

                    <div style="background: #ecfdf5; border-right: 4px solid #10b981; padding: 15px; border-radius: 6px;">
                        <h4 style="margin: 0 0 5px 0; color: #065f46; font-size: 14px;">✅ امنیت تضمین شده</h4>
                        <p style="margin: 0; color: #047857; font-size: 13px; line-height: 1.6;">
                            اپلیکیشن با پروتکل امن HTTPS و اعتبارسنجی سطح دسترسی مدیر فروشگاه به سایت متصل می‌شود و تمام پسوردها در حافظه امن و رمزگذاری شده سخت‌افزاری گوشی ذخیره می‌گردند.
                        </p>
                    </div>
                </div>
            </div>

            <!-- پاورقی برندینگ نوین سایت -->
            <div style="text-align: center; margin-top: 35px; padding: 18px; color: #64748b; font-size: 14px;">
                <p style="margin: 0; display: inline-flex; align-items: center; justify-content: center; gap: 6px;">
                    ساخته شده با 💚 توسط 
                    <a href="https://novinsite.com" target="_blank" rel="noopener noreferrer" style="color: #059669; font-weight: 700; text-decoration: none;">نوین سایت</a>
                </p>
            </div>
        </div>

        <!-- کتابخانه سبک تولید کد QR -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
        <script>
            (function() {
                var qrContainer = document.getElementById('qrcode');
                var qrLoading = document.getElementById('qr-loading');
                var btnRefresh = document.getElementById('btn-refresh-qr');
                var manualKey = document.getElementById('manual-key');
                var manualSecret = document.getElementById('manual-secret');
                var credBox = document.getElementById('credentials-box');
                var credUrl = document.getElementById('cred-url');
                var credKey = document.getElementById('cred-key');
                var qrcodeInstance = null;

                function generateNewKeys() {
                    qrLoading.style.display = 'block';
                    qrContainer.style.display = 'none';
                    qrContainer.innerHTML = '';

                    var xhr = new XMLHttpRequest();
                    xhr.open('POST', ajaxurl, true);
                    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
                    xhr.onload = function() {
                        if (xhr.status >= 200 && xhr.status < 400) {
                            var res = JSON.parse(xhr.responseText);
                            if (res.success && res.data) {
                                qrLoading.style.display = 'none';
                                qrContainer.style.display = 'block';

                                // رسم QR کد
                                qrcodeInstance = new QRCode(qrContainer, {
                                    text: 'WOO_APP:' + res.data.qr_payload,
                                    width: 220,
                                    height: 220,
                                    colorDark: "#1e1b4b",
                                    colorLight: "#ffffff",
                                    correctLevel: QRCode.CorrectLevel.M
                                });

                                manualKey.value = res.data.consumer_key;
                                manualSecret.value = res.data.consumer_secret;
                                credUrl.textContent = res.data.site_url;
                                credKey.textContent = res.data.consumer_key.substring(0, 15) + '...';
                                credBox.style.display = 'block';
                            } else {
                                qrLoading.textContent = 'خطا در ساخت کلید: ' + (res.data ? res.data.message : 'نامشخص');
                            }
                        } else {
                            qrLoading.textContent = 'خطا در ارتباط با سرور.';
                        }
                    };
                    xhr.send('action=wmac_generate_keys&nonce=<?php echo esc_js($nonce); ?>');
                }

                btnRefresh.addEventListener('click', function(e) {
                    e.preventDefault();
                    if (confirm('با تولید مجدد کلید، اتصال قبلی لغو شده و باید مجدداً در اپلیکیشن اسکن کنید. ادامه می‌دهید؟')) {
                        generateNewKeys();
                    }
                });

                // تولید خودکار کلید در بارگذاری صفحه
                generateNewKeys();
            })();
        </script>
        <?php
    }
}

// راه‌اندازی سینگلتون افزونه
WooMobileAppConnector::get_instance();
