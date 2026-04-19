@echo off
REM Quick Start Script for Windows - Flutter App

echo.
echo ========================================
echo Pest Detection - Mobile App Setup
echo ========================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✓ Flutter found: 
flutter --version

REM Get dependencies
echo.
echo Installing dependencies...
call flutter pub get
echo ✓ Dependencies installed

REM Show devices
echo.
echo Available devices:
flutter devices

echo.
echo ========================================
echo IMPORTANT: Backend URL Configuration
echo ========================================
echo.
echo Before running the app, update the backend URL in:
echo   lib/services/api_service.dart
echo.
echo Use one of these based on your setup:
echo   - Android Emulator: http://10.0.2.2:5000
echo   - iOS Simulator: http://localhost:5000  
echo   - Physical Device: http://^<YOUR_PC_IP^>:5000
echo.
echo To find your PC IP: ipconfig
echo.

pause
