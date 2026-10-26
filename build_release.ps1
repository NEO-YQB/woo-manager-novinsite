# NovinSite Store Manager - Android Release Build PowerShell Script
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  NovinSite Store Manager - Android Release Build" -ForegroundColor Cyan
Write-Host "  مدیریت فروشگاه نوین سایت - ساخت نسخه نهایی اندروید" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/4] دریافت پکیج‌های فلاتر (flutter pub get)..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] خطا در دریافت پکیج‌ها." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "[2/4] کامپایل و تولید خروجی نسخه نهایی اندروید (Release APK)..." -ForegroundColor Yellow
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] خطا در ساخت APK." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "[3/4] کپی کردن فایل APK به دایرکتوری releases..." -ForegroundColor Yellow
if (!(Test-Path "releases")) {
    New-Item -ItemType Directory -Path "releases" | Out-Null
}
Copy-Item -Path "build\app\outputs\flutter-apk\app-release.apk" -Destination "releases\app-release.apk" -Force

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  عملیات ساخت با موفقیت انجام شد!" -ForegroundColor Green
Write-Host "  فایل APK: releases\app-release.apk" -ForegroundColor Green
Write-Host "  فایل افزونه وردپرس: releases\woo-mobile-connector.zip" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
