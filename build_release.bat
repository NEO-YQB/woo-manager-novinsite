@echo off
chcp 65001 >nul
echo ========================================================
echo   NovinSite Store Manager - Android Release Build
echo   مدیریت فروشگاه نوین سایت - ساخت نسخه نهایی اندروید
echo ========================================================
echo.

echo [1/4] دریافت پکیج‌های فلاتر (flutter pub get)...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] خطا در دریافت پکیج‌ها. لطفاً اتصال اینترنت خود را بررسی کنید.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/4] کامپایل و تولید خروجی نسخه نهایی اندروید (Release APK)...
call flutter build apk --release
if %ERRORLEVEL% neq 0 (
    echo [ERROR] خطا در ساخت APK.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [3/4] کپی کردن فایل APK به دایرکتوری releases...
if not exist "releases" mkdir releases
copy /y "build\app\outputs\flutter-apk\app-release.apk" "releases\app-release.apk" >nul

echo.
echo [4/4] بسته‌بندی افزونه وردپرس...
echo فایل افزونه آماده در مسیر releases\woo-mobile-connector.zip قرار دارد.

echo.
echo ========================================================
echo   عملیات ساخت با موفقیت انجام شد!
echo   فایل APK: releases\app-release.apk
echo   فایل افزونه وردپرس: releases\woo-mobile-connector.zip
echo ========================================================
echo.
pause
