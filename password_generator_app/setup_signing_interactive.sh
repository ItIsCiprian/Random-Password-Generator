#!/bin/bash

# Interactive script to set up signing for Google Play Store

EXPECTED_SHA1="10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB"
KEY_PROPERTIES_FILE="android/key.properties"

echo "🔐 Google Play Store Signing Setup"
echo "==================================="
echo ""
echo "Expected SHA1: $EXPECTED_SHA1"
echo "Current AAB is using debug key (wrong)"
echo ""

# Check if key.properties already exists
if [ -f "$KEY_PROPERTIES_FILE" ]; then
    echo "⚠️  key.properties already exists!"
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

echo ""
echo "Step 1: Find your keystore file"
echo "-------------------------------"
echo ""

# Search for keystores
echo "Searching for keystore files..."
KEYSTORES=$(find ~ -maxdepth 5 -type f \( -name "*.jks" -o -name "*.keystore" \) 2>/dev/null | grep -v ".android/debug.keystore" | head -20)

if [ -z "$KEYSTORES" ]; then
    echo "❌ No keystore files found (excluding debug.keystore)"
    echo ""
    echo "You need to locate your original keystore file."
    echo "Common locations:"
    echo "  - ~/upload-keystore.jks"
    echo "  - ~/keystore.jks"
    echo "  - ~/Documents/"
    echo "  - ~/Downloads/"
    echo "  - Backup folders"
    echo ""
    read -rp "Enter the full path to your keystore file (or press Enter to skip): " KEYSTORE_PATH
    
    if [ -z "$KEYSTORE_PATH" ]; then
        echo ""
        echo "⚠️  Cannot proceed without keystore file."
        echo ""
        echo "Options:"
        echo "1. Find your keystore file and run this script again"
        echo "2. Contact Google Play Support if you lost it"
        exit 1
    fi
else
    echo "Found keystore files:"
    echo ""
    IFS=$'\n'
    KEYSTORE_ARRAY=($KEYSTORES)
    for i in "${!KEYSTORE_ARRAY[@]}"; do
        echo "  [$((i+1))] ${KEYSTORE_ARRAY[$i]}"
    done
    echo "  [0] Enter custom path"
    echo ""
    read -p "Select keystore (1-${#KEYSTORE_ARRAY[@]}, or 0): " SELECTION
    
    if [ "$SELECTION" = "0" ] || [ -z "$SELECTION" ]; then
        read -rp "Enter the full path to your keystore file: " KEYSTORE_PATH
    else
        KEYSTORE_PATH="${KEYSTORE_ARRAY[$((SELECTION-1))]}"
    fi
fi

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ File not found: $KEYSTORE_PATH"
    exit 1
fi

echo ""
echo "Step 2: Verify keystore fingerprint"
echo "-----------------------------------"
echo ""

# Try to get aliases
echo "Getting aliases from keystore..."
ALIASES=$(keytool -list -keystore "$KEYSTORE_PATH" 2>/dev/null | grep -i "alias" | awk '{print $3}')

if [ -z "$ALIASES" ]; then
    echo "⚠️  Could not read keystore. You'll need to enter the alias manually."
    read -rp "Enter key alias (common: upload, key, release): " KEY_ALIAS
else
    echo "Found aliases:"
    IFS=$'\n'
    ALIAS_ARRAY=($ALIASES)
    for i in "${!ALIAS_ARRAY[@]}"; do
        echo "  [$((i+1))] ${ALIAS_ARRAY[$i]}"
    done
    echo ""
    read -rp "Select alias (1-${#ALIAS_ARRAY[@]}): " ALIAS_SELECTION
    KEY_ALIAS="${ALIAS_ARRAY[$((ALIAS_SELECTION-1))]}"
fi

echo ""
echo "Checking fingerprint..."
SHA1=$(keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" 2>/dev/null | grep -i "SHA1" | head -1 | awk '{print $2}')

if [ -z "$SHA1" ]; then
    echo "❌ Could not read keystore. Please check:"
    echo "   - File path is correct"
    echo "   - Alias name is correct"
    echo "   - Keystore is not corrupted"
    exit 1
fi

echo "Found SHA1: $SHA1"
echo ""

if [ "$SHA1" = "$EXPECTED_SHA1" ]; then
    echo "✅ MATCH! This is the correct keystore!"
else
    echo "❌ Does NOT match expected fingerprint"
    echo ""
    echo "Expected: $EXPECTED_SHA1"
    echo "Found:    $SHA1"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled. Please find the correct keystore."
        exit 1
    fi
fi

echo ""
echo "Step 3: Get keystore password"
echo "-----------------------------"
read -sp "Enter keystore password: " STORE_PASSWORD
echo ""
read -sp "Enter key password (usually same as keystore): " KEY_PASSWORD
echo ""

if [ -z "$STORE_PASSWORD" ]; then
    echo "❌ Password cannot be empty"
    exit 1
fi

if [ -z "$KEY_PASSWORD" ]; then
    KEY_PASSWORD="$STORE_PASSWORD"
fi

echo ""
echo "Step 4: Create key.properties file"
echo "-----------------------------------"

# Get absolute path
ABS_KEYSTORE_PATH=$(realpath "$KEYSTORE_PATH" 2>/dev/null || echo "$KEYSTORE_PATH")

# Create key.properties
cat > "$KEY_PROPERTIES_FILE" << EOF
storeFile=$ABS_KEYSTORE_PATH
storePassword=$STORE_PASSWORD
keyAlias=$KEY_ALIAS
keyPassword=$KEY_PASSWORD
EOF

echo "✅ Created $KEY_PROPERTIES_FILE"
echo ""
echo "Contents:"
echo "  storeFile=$ABS_KEYSTORE_PATH"
echo "  keyAlias=$KEY_ALIAS"
echo "  storePassword=***"
echo "  keyPassword=***"
echo ""

echo "Step 5: Verify setup"
echo "--------------------"
echo "Rebuilding AAB with correct signing key..."
echo ""

cd "$(dirname "$0")" || exit
flutter clean > /dev/null 2>&1
if flutter build appbundle --release; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Verifying signature..."
    NEW_SHA1=$(keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab 2>/dev/null | grep -i "SHA1" | head -1 | awk '{print $2}')
    
    if [ "$NEW_SHA1" = "$EXPECTED_SHA1" ]; then
        echo "✅ Signature matches! AAB is ready for upload."
    else
        echo "⚠️  Signature verification:"
        echo "   Expected: $EXPECTED_SHA1"
        echo "   Found:    $NEW_SHA1"
        echo ""
        echo "The AAB was built but signature doesn't match."
    fi
    
    echo ""
    echo "📦 AAB Location:"
    echo "   build/app/outputs/bundle/release/app-release.aab"
    echo ""
    echo "🚀 Ready to upload to Google Play Store!"
else
    echo ""
    echo "❌ Build failed. Check the errors above."
    exit 1
fi

