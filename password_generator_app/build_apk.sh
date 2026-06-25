#!/bin/bash

# Build APK Script for Cipher Generator
# This script will build the APK file for manual installation

echo "🔨 Building Cipher Generator APK..."
echo "===================================="
echo ""

# Try to find Flutter
FLUTTER_CMD="flutter"

# Check common Flutter locations
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter not found in PATH"
    echo ""
    echo "Please either:"
    echo "1. Add Flutter to your PATH, or"
    echo "2. Run this command manually:"
    echo ""
    echo "   cd $(pwd)"
    echo "   flutter pub get"
    echo "   flutter build apk"
    echo ""
    echo "Or if Flutter is installed elsewhere, update the FLUTTER_CMD variable in this script."
    exit 1
fi

# Navigate to app directory
cd "$(dirname "$0")" || exit

echo "📁 Current directory: $(pwd)"
echo ""

# Check Flutter version
echo "📱 Checking Flutter installation..."
$FLUTTER_CMD --version
echo ""

# Install dependencies
echo "📥 Installing dependencies..."
if ! $FLUTTER_CMD pub get; then
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
$FLUTTER_CMD clean
echo ""

# Build APK
echo "🔨 Building APK (this may take a few minutes)..."
if $FLUTTER_CMD build apk --release; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📦 APK Location:"
    echo "   $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📱 To install on your phone:"
    echo "   1. Transfer the APK file to your phone"
    echo "   2. Enable 'Install from Unknown Sources' in Settings"
    echo "   3. Open the APK file and install"
    echo ""
    echo "💡 File size:"
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk 2>/dev/null | awk '{print $1}')
    echo "    Size: $APK_SIZE"
    echo ""
else
    echo ""
    echo "❌ Build failed. Check the errors above."
    exit 1
fi

