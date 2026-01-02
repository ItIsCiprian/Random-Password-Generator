#!/bin/bash

# Script to find and verify keystore files
# This helps locate the correct keystore for Play Store signing

echo "🔍 Finding Keystore Files"
echo "========================"
echo ""

EXPECTED_SHA1="10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB"

echo "Expected SHA1 fingerprint:"
echo "$EXPECTED_SHA1"
echo ""

# Find all keystore files
echo "🔎 Searching for keystore files (.jks, .keystore)..."
echo ""

KEYSTORES=$(find ~ -type f \( -name "*.jks" -o -name "*.keystore" \) 2>/dev/null)

if [ -z "$KEYSTORES" ]; then
    echo "❌ No keystore files found in home directory"
    echo ""
    echo "Common locations to check manually:"
    echo "  - ~/upload-keystore.jks"
    echo "  - ~/android/app/upload-keystore.jks"
    echo "  - ~/keystore.jks"
    echo "  - ~/Documents/"
    echo "  - ~/Downloads/"
    echo ""
    echo "If you can't find your keystore, you may need to:"
    echo "  1. Contact Google Play Support to reset your signing key"
    echo "  2. Or create a new app listing with a new keystore"
    exit 1
fi

echo "Found keystore files:"
echo "$KEYSTORES" | while read -r keystore; do
    echo "  📦 $keystore"
done
echo ""

# Check each keystore
echo "🔐 Checking keystore fingerprints..."
echo ""

MATCH_FOUND=false

echo "$KEYSTORES" | while read -r keystore; do
    echo "Checking: $keystore"
    
    # Try to list aliases
    ALIASES=$(keytool -list -keystore "$keystore" 2>/dev/null | grep -i "alias" | awk '{print $3}')
    
    if [ -z "$ALIASES" ]; then
        echo "  ⚠️  Could not read keystore (may need password)"
        echo ""
        continue
    fi
    
    echo "$ALIASES" | while read -r alias; do
        if [ -n "$alias" ]; then
            SHA1=$(keytool -list -v -keystore "$keystore" -alias "$alias" 2>/dev/null | grep -i "SHA1" | head -1 | awk '{print $2}')
            
            if [ -n "$SHA1" ]; then
                echo "  Alias: $alias"
                echo "  SHA1:  $SHA1"
                
                if [ "$SHA1" = "$EXPECTED_SHA1" ]; then
                    echo "  ✅ MATCH! This is the correct keystore!"
                    echo ""
                    echo "  Use this in android/key.properties:"
                    echo "    storeFile=$keystore"
                    echo "    keyAlias=$alias"
                    echo ""
                    MATCH_FOUND=true
                else
                    echo "  ❌ Does not match"
                fi
                echo ""
            fi
        fi
    done
done

echo ""
echo "=========================================="
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. If you found the matching keystore:"
echo "   - Create android/key.properties file"
echo "   - Add the keystore path and alias"
echo "   - Rebuild: flutter build appbundle --release"
echo ""
echo "2. If you can't find the keystore:"
echo "   - Contact Google Play Support"
echo "   - They can help reset your signing key"
echo ""
echo "3. To manually check a keystore:"
echo "   keytool -list -v -keystore /path/to/keystore.jks -alias your_alias"
echo ""

