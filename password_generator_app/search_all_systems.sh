#!/bin/bash

# Comprehensive search for Android keystore across the entire system
# Since repo was cloned fresh, keystore must be from previous work

EXPECTED_SHA1="10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB"

echo "🔍 Comprehensive Keystore Search"
echo "================================="
echo ""
echo "Searching entire system for Android keystore files..."
echo "Expected SHA1: $EXPECTED_SHA1"
echo ""

# Search in common developer locations
echo "Searching common developer locations..."
echo ""

LOCATIONS=(
    "$HOME"
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Desktop"
    "$HOME/Developer"
    "$HOME/Projects"
    "$HOME/android"
    "$HOME/.android"
)

FOUND_FILES=()

for LOC in "${LOCATIONS[@]}"; do
    if [ -d "$LOC" ]; then
        echo "Checking: $LOC"
        FILES=$(find "$LOC" -maxdepth 4 -type f \( -name "*.jks" -o -name "*.keystore" \) 2>/dev/null | grep -v ".android/debug.keystore" | grep -v ".local/share/keyrings")
        
        if [ -n "$FILES" ]; then
            while IFS= read -r FILE; do
                if [ -f "$FILE" ]; then
                    FOUND_FILES+=("$FILE")
                    echo "  ✓ Found: $FILE"
                fi
            done <<< "$FILES"
        fi
    fi
done

echo ""

if [ ${#FOUND_FILES[@]} -eq 0 ]; then
    echo "❌ No keystore files found in common locations"
    echo ""
    echo "The keystore is not in this repository (as expected - it shouldn't be in git)."
    echo ""
    echo "Possible scenarios:"
    echo "1. Keystore is on another machine where you originally developed the app"
    echo "2. Keystore is in cloud storage (Google Drive, Dropbox, etc.)"
    echo "3. Keystore was backed up to USB drive or external storage"
    echo "4. Keystore was emailed to yourself"
    echo "5. Keystore was lost/deleted"
    echo ""
    echo "Next steps:"
    echo "==========="
    echo ""
    echo "Option 1: Search Other Locations"
    echo "  - Check other computers you've used"
    echo "  - Check cloud storage (Google Drive, Dropbox, OneDrive)"
    echo "  - Check email for 'keystore' or 'jks' attachments"
    echo "  - Check USB drives or external backups"
    echo ""
    echo "Option 2: Contact Google Play Support"
    echo "  - Go to: https://play.google.com/console"
    echo "  - Help → Contact Us"
    echo "  - Explain you lost your signing key"
    echo "  - Provide SHA1: $EXPECTED_SHA1"
    echo "  - They may be able to help (requires verification)"
    echo ""
    echo "Option 3: Create New App (if key is truly lost)"
    echo "  - Create new app listing in Play Console"
    echo "  - Use new package name"
    echo "  - Create new keystore"
    echo "  - Users will need to download new app"
    exit 1
fi

echo "Found ${#FOUND_FILES[@]} potential keystore file(s):"
echo ""

for i in "${!FOUND_FILES[@]}"; do
    FILE="${FOUND_FILES[$i]}"
    SIZE=$(ls -lh "$FILE" 2>/dev/null | awk '{print $5}')
    echo "  [$((i+1))] $FILE ($SIZE)"
done

echo ""
echo "Checking fingerprints..."
echo ""

MATCH_FOUND=false
for FILE in "${FOUND_FILES[@]}"; do
    echo "Checking: $(basename "$FILE")"
    
    # Try to list aliases (some keystores can be listed without password)
    ALIASES=$(keytool -list -keystore "$FILE" 2>/dev/null | grep -i "alias" | awk '{print $3}')
    
    if [ -z "$ALIASES" ]; then
        echo "  ⚠️  Needs password to read"
        echo ""
        continue
    fi
    
    for ALIAS in $ALIASES; do
        SHA1=$(keytool -list -v -keystore "$FILE" -alias "$ALIAS" 2>/dev/null | grep -i "SHA1" | head -1 | awk '{print $2}')
        
        if [ -n "$SHA1" ]; then
            echo "  Alias: $ALIAS"
            echo "  SHA1:  $SHA1"
            
            if [ "$SHA1" = "$EXPECTED_SHA1" ]; then
                echo "  ✅✅✅ MATCH FOUND! ✅✅✅"
                echo ""
                echo "  File: $FILE"
                echo "  Alias: $ALIAS"
                echo ""
                echo "  Create android/key.properties with:"
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
    echo "❌ No matching keystore found in searched locations"
    echo ""
    echo "You'll need to:"
    echo "1. Check other machines/backups"
    echo "2. Contact Google Play Support"
    echo "3. Or create a new app listing"
fi















