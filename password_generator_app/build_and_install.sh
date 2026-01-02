#!/bin/bash

# Build and Install Script for Cipher Generator
# This script will build the app and install it on your connected Android device

echo "🔨 Cipher Generator - Build & Install Script"
echo "=============================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev"
    exit 1
fi

# Check Flutter version
echo "📱 Checking Flutter installation..."
flutter --version
echo ""

# Navigate to app directory
cd "$(dirname "$0")"

# Check for connected devices
echo "🔍 Checking for connected devices..."
DEVICES=$(flutter devices | grep -c "•")

if [ "$DEVICES" -eq 0 ]; then
    echo "⚠️  No devices found!"
    echo ""
    echo "Please:"
    echo "1. Connect your Android phone via USB"
    echo "2. Enable USB Debugging on your phone"
    echo "3. Run 'flutter devices' to verify connection"
    echo ""
    read -p "Do you want to build APK anyway? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Building APK..."
        flutter build apk
        echo ""
        echo "✅ APK built successfully!"
        echo "📁 Location: build/app/outputs/flutter-apk/app-release.apk"
        echo ""
        echo "Transfer this file to your phone and install it manually."
    else
        echo "❌ Build cancelled"
        exit 1
    fi
else
    echo "✅ Found $DEVICES device(s)"
    flutter devices
    echo ""
    
    # Install dependencies
    echo "📥 Installing dependencies..."
    flutter pub get
    echo ""
    
    # Build and install
    echo "🚀 Building and installing on device..."
    flutter run --release
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ App installed successfully!"
        echo "🎉 You can now use Cipher Generator on your phone!"
    else
        echo ""
        echo "❌ Installation failed. Check the errors above."
        exit 1
    fi
fi

