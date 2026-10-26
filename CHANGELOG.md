# Changelog

All notable changes to the **NovinSite WooCommerce Store Manager** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-10-26

### Added
- **Executive Store Dashboard**:
  - Live revenue analytics (Today, Month, Pending, Processing).
  - Low stock & out-of-stock inventory alerts.
  - Interactive 7-day sales breakdown chart using `fl_chart`.
  - Recent orders timeline with customer avatar and status badge.
- **Push & Local Notifications**:
  - Instant sound and vibration alerts when new orders are placed.
  - Dedicated notification center with unread badge counter in top app bar.
  - 1-tap test notification trigger for store managers.
- **Order Management & Quick Actions**:
  - Multi-status filter tabs (All, Processing, Completed, Pending, On Hold, Cancelled, Refunded).
  - Instant status changing (2-tap order update).
  - Order private and customer notes logging.
- **Customer Communication**:
  - 1-Tap Direct phone call (`tel:`).
  - Pre-filled WhatsApp direct message (`wa.me`).
  - Pre-filled SMS messaging (`sms:`).
- **Official PDF Invoice Generation & Direct Printing**:
  - High-res vector A4 invoice compliant with Iranian commerce standards.
  - Vazirmatn Persian typography rendering.
  - Dynamic QR verification barcode.
  - Wireless / thermal printer dispatch and multi-app sharing.
- **Product Management & Quick Edit**:
  - Catalog browsing with search and stock status filter.
  - Instant modal quick edit for regular price, sale price, and stock count.
  - Full product creation and update screen.
- **Bilingual & Localization**:
  - Dynamic switching between **Persian (فارسی - RTL)** and **English (LTR)**.
  - Persian (Jalali) and Gregorian calendar support.
  - Persian (۱۲۳) and English (123) numerical formatting.
- **Companion WordPress Plugin (`woo-mobile-connector`)**:
  - Dedicated WP Admin menu with 1-click QR code pairing.
  - Aggregated high-speed `/wp-json/woo-app/v1/dashboard-summary` endpoint.
  - Order hook logger for real-time notification sync.
  - Packaged as clean production zip `woo-mobile-connector.zip`.
- **CI/CD & Release Automation**:
  - GitHub Actions workflow for automated APK building and plugin archiving.
  - 1-Click Windows build scripts (`build_release.bat` & `build_release.ps1`).
