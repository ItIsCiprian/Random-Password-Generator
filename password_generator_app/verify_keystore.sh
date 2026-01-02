#!/bin/bash

# Script to verify keystore fingerprint matches expected value

EXPECTED_SHA1="10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB"

echo "🔐 Keystore Fingerprint Verifier"
echo "================================"
echo ""
echo "Expected SHA1: $EXPECTED_SHA1"
echo ""

if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-keystore.jks> [alias]"
    echo ""
    echo "Example:"
    echo "  $0 ~/upload-keystore.jks upload"
    echo ""
    exit 1
fi

KEYSTORE="$1"
ALIAS="${2:-upload}"

if [ ! -f "$KEYSTORE" ]; then
    echo "❌ Keystore file not found: $KEYSTORE"
    exit 1
fi

echo "Checking keystore: $KEYSTORE"
echo "Alias: $ALIAS"
echo ""

# Get SHA1 fingerprint
SHA1=$(keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" 2>/dev/null | grep -i "SHA1" | head -1 | awk '{print $2}')

if [ -z "$SHA1" ]; then
    echo "❌ Could not read keystore. Possible issues:"
    echo "   - Wrong password"
    echo "   - Wrong alias name"
    echo "   - Keystore file is corrupted"
    echo ""
    echo "Try listing aliases:"
    echo "  keytool -list -keystore $KEYSTORE"
    exit 1
fi

echo "Found SHA1: $SHA1"
echo ""

if [ "$SHA1" = "$EXPECTED_SHA1" ]; then
    echo "✅ MATCH! This is the correct keystore!"
    echo ""
    echo "📝 Add this to android/key.properties:"
    echo "   storeFile=$(realpath "$KEYSTORE")"
    echo "   keyAlias=$ALIAS"
    echo "   storePassword=your_password"
    echo "   keyPassword=your_password"
else
    echo "❌ Does NOT match expected fingerprint"
    echo ""
    echo "This keystore cannot be used for this app."
    echo "You need to find the keystore with SHA1:"
    echo "   $EXPECTED_SHA1"
fi

