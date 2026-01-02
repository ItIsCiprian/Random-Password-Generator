#!/bin/bash

# Build both APK and AAB Script for Cipher Generator
# This script will build both APK and AAB files

echo "🔨 Building Cipher Generator - APK and AAB"
echo "==========================================="
echo ""

# Navigate to app directory
cd "$(dirname "$0")"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found in PATH"
    echo "Please add Flutter to your PATH or use full path"
    exit 1
fi

echo "📱 Flutter version:"
flutter --version
echo ""

# Install dependencies
echo "📥 Installing dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo ""

# Build APK
echo "🔨 Building APK (this may take a few minutes)..."
flutter build apk --release
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK build successful!"
    echo "📦 APK Location:"
    echo "   $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
    APK_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-release.apk 2>/dev/null | awk '{print $5}')
    echo "   Size: $APK_SIZE"
    echo ""
else
    echo "❌ APK build failed"
    exit 1
fi

# Build AAB
echo "🔨 Building AAB (Android App Bundle) for Play Store..."
flutter build appbundle --release
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ AAB build successful!"
    echo "📦 AAB Location:"
    echo "   $(pwd)/build/app/outputs/bundle/release/app-release.aab"
    AAB_SIZE=$(ls -lh build/app/outputs/bundle/release/app-release.aab 2>/dev/null | awk '{print $5}')
    echo "   Size: $AAB_SIZE"
    echo ""
else
    echo "❌ AAB build failed"
    exit 1
fi

echo "==========================================="
echo "✅ Both builds completed successfully!"
echo ""
echo "📱 APK: For direct installation on devices"
echo "   $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "📦 AAB: For Google Play Store upload"
echo "   $(pwd)/build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "💡 Note: AAB files are optimized for Play Store distribution"
echo "   and cannot be installed directly on devices."
echo ""

