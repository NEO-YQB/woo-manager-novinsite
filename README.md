# NovinSite WooCommerce Store Manager 📱💼

<div align="center">

<img src="assets/images/logo.png" width="120" alt="NovinSite Logo" />

### An Executive Flutter Android App & Companion WordPress Plugin for Managing WooCommerce Stores Anywhere, Anytime.

[![Language](https://img.shields.io/badge/Language-Persian%20%7C%20English-blue.svg)](#-bilingual-support)
[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![WooCommerce](https://img.shields.io/badge/WooCommerce-REST%20API%20v3-96588A?logo=woocommerce&logoColor=white)](https://woocommerce.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Developed%20by-NovinSite-10b981.svg)](https://novinsite.com)

**[🇮🇷 مطالعه به زبان فارسی (Persian Documentation)](README_FA.md)** | **[🇺🇸 English Documentation](README.md)**

</div>

---

> **Built with 💚 by [NovinSite](https://novinsite.com)**

**NovinSite WooCommerce Store Manager** is a high-performance, feature-packed Flutter Android application paired with a custom WordPress companion plugin. It empowers online store owners and managers to monitor live revenue, process orders, print official Persian/English PDF invoices, communicate with customers via 1-tap WhatsApp/Phone calls, update product prices on the fly, and receive instant push notifications for new orders.

---

## 🌟 Key Features

### 📊 1. Executive Real-Time Dashboard
- **Live KPI Analytics**: Daily & monthly gross sales, processing orders, pending payments, and revenue totals.
- **Inventory Health Alerts**: Instant counter for low-stock and out-of-stock products.
- **7-Day Sales Trend**: Interactive bar chart built with `fl_chart`.
- **Recent Orders Stream**: Live timeline of newly placed orders with customer avatars and status indicators.

### 🔔 2. Push & Local Notifications
- **Instant Order Alerts**: Receive real-time Android notifications (sound & vibration) whenever a customer completes a purchase.
- **App Bar Notification Bell**: Bell icon with unread badge counter in the top bar.
- **Notification Center**: Dedicated screen to review recent store events, navigate to order details, or trigger test notifications.

### 📦 3. Advanced Orders Management
- **Status Filter Tabs**: Filter by *All, Processing, Completed, Pending, On Hold, Cancelled, and Refunded*.
- **Quick Status Change**: Update order status in just 2 taps.
- **Instant Search**: Search by Order ID, customer name, email, or phone number.
- **Order Notes**: View order timeline, add private internal notes, or add customer notes that trigger WooCommerce emails.

### 🧾 4. Official PDF Invoice & Wireless Printing
- **Commercial-Grade Invoicing**: Vector A4 PDF invoice generator supporting both Persian (Vazirmatn) and English layouts.
- **Store & Customer Details**: Seller logo, contact info, national ID/economic code, buyer details, and full itemized pricing table (subtotal, discounts, shipping, tax, grand total).
- **QR Code Verification**: Embedded QR code for invoice authenticity verification.
- **Print & Share**: Direct thermal / Wi-Fi printing (`printing`) and 1-tap PDF sharing via WhatsApp, Telegram, or email.

### 📞 5. One-Tap Customer Communication
- 📞 **Direct Call**: Launch native phone dialer with customer's number prefilled.
- 💬 **WhatsApp Chat**: Open WhatsApp conversation with prefilled Persian/English order greeting templates.
- ✉️ **SMS**: Open default SMS messaging app with customer details.

### 🏷️ 6. Product Catalog & Quick Edit
- **Catalog Browsing**: Thumbnail previews, SKU codes, regular price, sale price, and inventory stock status.
- **Quick Edit Sheet**: Update product price, sale price, and stock count in seconds without loading heavy screens.
- **Full Editor**: Add new products or edit complete descriptions, categories, and attributes.

### 🔒 7. Hardware Keystore Security & Biometrics
- **Encrypted Storage**: Consumer keys and secrets are securely saved using Android Keystore (`flutter_secure_storage`).
- **Biometric App Lock**: Optional Fingerprint / Face ID / PIN screen lock.

### 🌐 8. Bilingual & Localization Engine
- **Persian & English**: Seamlessly switch languages in the Settings screen.
- **Automatic Layout Direction**: Full Right-to-Left (RTL) for Persian and Left-to-Right (LTR) for English.
- **Dual Calendar**: Persian Solar Hijri (Jalali) or Gregorian calendar.
- **Dual Digits**: Persian numbers (`۱۲۳`) or English digits (`123`).

---

## 🔌 WordPress Companion Plugin (`woo-mobile-connector`)

A dedicated WordPress plugin is provided in [`wordpress-plugin/woo-mobile-connector/`](wordpress-plugin/woo-mobile-connector/):
- **1-Click QR Pairing**: Generates a secure QR code in the WordPress Admin menu (`📱 NovinSite Store`) for instant pairing without manually typing 40-character API keys.
- **5x Faster Analytics**: Aggregated `/wp-json/woo-app/v1/dashboard-summary` endpoint reduces database queries and cuts mobile load time by 80%.
- **Order Event Logger**: Hooks into `woocommerce_new_order` and status transitions to serve notification feeds.

---

## 📦 Production Downloads & Releases

Pre-packaged release binaries are available in the [`releases/`](releases/) directory:
- 📱 **Android Release APK**: `releases/app-release.apk`
- 🔌 **WordPress Plugin (ZIP)**: `releases/woo-mobile-connector.zip` (Ready to upload in WP Admin > Plugins > Add New > Upload Plugin)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.22+
- Android Studio / VS Code with Android SDK 35+
- WordPress 5.8+ with WooCommerce 5.0+

### Local Setup
```bash
# Clone the repository
git clone https://github.com/your-username/novinsite-woo-manager.git
cd novinsite-woo-manager

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Building the Release APK on Windows
Double-click `build_release.bat` or run:
```powershell
.\build_release.ps1
```
Output APK is copied automatically to `releases/app-release.apk`.

---

## 🛠️ Tech Stack & Dependencies

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `provider` | ^6.1.2 | State management |
| `dio` | ^5.7.0 | High-performance HTTP client |
| `flutter_secure_storage` | ^9.2.2 | Android Keystore hardware encryption |
| `flutter_local_notifications` | ^18.0.1 | Push and background notifications |
| `fl_chart` | ^0.69.0 | Smooth, interactive analytics charts |
| `pdf` & `printing` | ^3.11.1 / ^5.13.0 | Vector PDF invoice generator & printer |
| `mobile_scanner` | ^5.2.3 | Camera QR code scanner for instant setup |
| `local_auth` | ^2.3.0 | Biometric authentication (Fingerprint / Face) |
| `shamsi_date` | ^1.0.8 | Persian (Jalali) solar calendar conversion |
| `url_launcher` | ^6.3.0 | Direct Phone, SMS, and WhatsApp actions |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <b>Developed with 💚 by <a href="https://novinsite.com">NovinSite</a></b><br/>
  Empowering Modern E-Commerce
</div>
