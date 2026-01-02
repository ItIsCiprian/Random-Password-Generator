#!/bin/bash

# Better script to find Android keystore files (excluding system keyrings)

EXPECTED_SHA1="10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB"

echo "🔍 Searching for Android Keystore Files"
echo "======================================="
echo ""
echo "Expected SHA1: $EXPECTED_SHA1"
echo ""

# Search for .jks files (Java KeyStore - Android format)
echo "Searching for .jks files..."
JKS_FILES=$(find ~ -maxdepth 6 -type f -name "*.jks" 2>/dev/null | grep -v ".local/share/keyrings" | grep -v ".android/debug.keystore")

# Search for .keystore files
echo "Searching for .keystore files..."
KEYSTORE_FILES=$(find ~ -maxdepth 6 -type f -name "*.keystore" 2>/dev/null | grep -v ".local/share/keyrings" | grep -v ".android/debug.keystore")

ALL_FILES=$(echo -e "$JKS_FILES\n$KEYSTORE_FILES" | grep -v "^$" | sort -u)

if [ -z "$ALL_FILES" ]; then
    echo "❌ No Android keystore files found"
    echo ""
    echo "Common locations to check manually:"
    echo "  - ~/upload-keystore.jks"
    echo "  - ~/keystore.jks"
    echo "  - ~/Documents/"
    echo "  - ~/Downloads/"
    echo "  - ~/android/app/"
    echo "  - Any backup folders"
    echo ""
    echo "Also check:"
    echo "  - Email attachments (if you emailed it to yourself)"
    echo "  - Cloud storage (Google Drive, Dropbox, etc.)"
    echo "  - USB drives or external backups"
    echo ""
    exit 1
fi

echo "Found potential Android keystore files:"
echo ""
IFS=$'\n'
FILE_ARRAY=($ALL_FILES)
for i in "${!FILE_ARRAY[@]}"; do
    FILE="${FILE_ARRAY[$i]}"
    SIZE=$(ls -lh "$FILE" 2>/dev/null | awk '{print $5}')
    echo "  [$((i+1))] $FILE ($SIZE)"
done
echo ""

echo "Checking each file..."
echo ""

MATCH_FOUND=false
for FILE in "${FILE_ARRAY[@]}"; do
    echo "Checking: $FILE"
    
    # Try to list without password first (some keystores allow this)
    ALIASES=$(keytool -list -keystore "$FILE" -storepass "" 2>/dev/null | grep -i "alias" | awk '{print $3}')
    
    # If that didn't work, try with common passwords
    if [ -z "$ALIASES" ]; then
        for PASS in "android" "changeit" ""; do
            ALIASES=$(keytool -list -keystore "$FILE" -storepass "$PASS" 2>/dev/null | grep -i "alias" | awk '{print $3}')
            if [ -n "$ALIASES" ]; then
                break
            fi
        done
    fi
    
    if [ -z "$ALIASES" ]; then
        echo "  ⚠️  Cannot read (needs password or wrong format)"
        echo ""
        continue
    fi
    
    echo "  Aliases found: $ALIASES"
    
    # Check each alias
    for ALIAS in $ALIASES; do
        SHA1=$(keytool -list -v -keystore "$FILE" -alias "$ALIAS" -storepass "" 2>/dev/null | grep -i "SHA1" | head -1 | awk '{print $2}')
        
        if [ -z "$SHA1" ]; then
            for PASS in "android" "changeit" ""; do
                SHA1=$(keytool -list -v -keystore "$FILE" -alias "$ALIAS" -storepass "$PASS" 2>/dev/null | grep -i "SHA1" | head -1 | awk '{print $2}')
                if [ -n "$SHA1" ]; then
                    break
                fi
            done
        fi
        
        if [ -n "$SHA1" ]; then
            echo "  Alias: $ALIAS"
            echo "  SHA1:  $SHA1"
            
            if [ "$SHA1" = "$EXPECTED_SHA1" ]; then
                echo "  ✅✅✅ MATCH FOUND! ✅✅✅"
                echo ""
                echo "  This is your keystore!"
                echo "  File: $FILE"
                echo "  Alias: $ALIAS"
                echo ""
                echo "  To use it, create android/key.properties:"
                echo "    storeFile=$(realpath "$FILE" 2>/dev/null || echo "$FILE")"
                echo "    keyAlias=$ALIAS"
                echo "    storePassword=your_password"
                echo "    keyPassword=your_password"
                echo ""
                MATCH_FOUND=true
            else
                echo "  ❌ Does not match"
            fi
            echo ""
        fi
    done
done

if [ "$MATCH_FOUND" = false ]; then
    echo "=========================================="
    echo "❌ No matching keystore found"
    echo ""
    echo "The keystore with SHA1 $EXPECTED_SHA1 was not found."
    echo ""
    echo "Next steps:"
    echo "1. Check backup locations (external drives, cloud storage)"
    echo "2. Check if you emailed it to yourself"
    echo "3. Contact Google Play Support if you lost it"
    echo ""
fi

