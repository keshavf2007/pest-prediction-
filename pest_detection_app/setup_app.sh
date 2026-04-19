#!/bin/bash
# Quick Start Script for macOS/Linux - Flutter App

echo ""
echo "========================================"
echo "Pest Detection - Mobile App Setup"
echo "========================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✓ Flutter found:"
flutter --version

# Get dependencies
echo ""
echo "Installing dependencies..."
flutter pub get
echo "✓ Dependencies installed"

# Show devices
echo ""
echo "Available devices:"
flutter devices

echo ""
echo "========================================"
echo "IMPORTANT: Backend URL Configuration"
echo "========================================"
echo ""
echo "Before running the app, update the backend URL in:"
echo "   lib/services/api_service.dart"
echo ""
echo "Use one of these based on your setup:"
echo "   - Android Emulator: http://10.0.2.2:5000"
echo "   - iOS Simulator: http://localhost:5000"
echo "   - Physical Device: http://<YOUR_PC_IP>:5000"
echo ""
echo "To find your PC IP: ifconfig"
echo ""

read -p "Press Enter to continue..."
