#!/bin/bash

# Build & Install Script for the iOS + Apple Watch companion app (Cipher Generator)
# Builds the Runner (iPhone) scheme and installs it on a booted iPhone simulator,
# then installs and launches the watch app on the watch simulator paired with that iPhone.
#
# Usage:
#   ./build_ios_watch.sh
#   ./build_ios_watch.sh --phone <UDID> --watch <UDID>
#   ./build_ios_watch.sh --no-launch

set -euo pipefail

echo "🍎 Cipher Generator - iOS + Watch Build & Install"
echo "=================================================="
echo ""

# --- Resolve Xcode developer dir --------------------------------------------
XCODE_DEV="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
if [ ! -d "$XCODE_DEV" ]; then
    echo "❌ Xcode not found at $XCODE_DEV"
    exit 1
fi
export DEVELOPER_DIR="$XCODE_DEV"
echo "✅ Xcode: $XCODE_DEV"
echo ""

# --- Parse arguments ---------------------------------------------------------
PHONE_UDID=""
WATCH_UDID=""
DO_LAUNCH=1
while [ $# -gt 0 ]; do
    case "$1" in
        --phone)   PHONE_UDID="$2"; shift 2 ;;
        --watch)   WATCH_UDID="$2"; shift 2 ;;
        --no-launch) DO_LAUNCH=0; shift ;;
        *) echo "❌ Unknown argument: $1"; exit 1 ;;
    esac
done

SIMCTL="xcrun simctl"

# --- Auto-detect booted iPhone ----------------------------------------------
if [ -z "$PHONE_UDID" ]; then
    PHONE_UDID=$($SIMCTL list devices booted 2>/dev/null | grep -E "iPhone" | grep -oE "[0-9A-F-]{36}" | head -1)
    if [ -z "$PHONE_UDID" ]; then
        echo "❌ No booted iPhone simulator found."
        echo "   Boot one with: open -a Simulator  (or: xcrun simctl boot <udid>)"
        exit 1
    fi
fi
echo "📱 iPhone simulator: $PHONE_UDID"

# --- Auto-detect booted watch paired with the iPhone ------------------------
if [ -z "$WATCH_UDID" ]; then
    WATCH_UDID=$($SIMCTL list pairs 2>/dev/null | grep -B1 -A2 "Phone: .*($PHONE_UDID)" \
        | grep -oE "Watch: .*\(([0-9A-F-]{36})\)" | grep -oE "[0-9A-F-]{36}" | head -1 || true)
    if [ -z "$WATCH_UDID" ]; then
        WATCH_UDID=$($SIMCTL list devices booted 2>/dev/null | grep -iE "watch" | grep -oE "[0-9A-F-]{36}" | head -1)
    fi
    if [ -z "$WATCH_UDID" ]; then
        echo "⚠️  No paired/booted Apple Watch simulator found - watch app will not be installed."
        export SKIP_WATCH=1
    fi
fi
if [ -n "${SKIP_WATCH:-}" ]; then
    :
elif [ -n "$WATCH_UDID" ]; then
    echo "⌚ Watch simulator: $WATCH_UDID"
fi

# --- Build -------------------------------------------------------------------
echo ""
echo "🔨 Building Runner (iPhone) scheme..."
BUILD_DIR="$(pwd)/build/ios-simulator"
DEVELOPER_DIR="$XCODE_DEV" xcodebuild \
    -project ios/Runner.xcodeproj \
    -scheme Runner \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$PHONE_UDID" \
    -derivedDataPath "$BUILD_DIR" \
    build > /tmp/cipher_ios_watch_build.log 2>&1 || {
        echo "❌ Build failed. Last lines:"
        tail -30 /tmp/cipher_ios_watch_build.log
        exit 1
    }
echo "✅ Build succeeded"

RUNNER_APP="$BUILD_DIR/Build/Products/Debug-iphonesimulator/Runner.app"
WATCH_APP="$BUILD_DIR/Build/Products/Debug-watchsimulator/WatchApp.app"

if [ ! -d "$RUNNER_APP" ]; then
    echo "❌ Runner.app not found at $RUNNER_APP"
    exit 1
fi
echo "   iPhone app: $RUNNER_APP"

APP_BUNDLE_ID="com.example.passwordGeneratorApp"
WATCH_BUNDLE_ID="com.example.passwordGeneratorApp.watchkitapp"

# --- Install & launch on iPhone ----------------------------------------------
echo ""
echo "📲 Installing on iPhone simulator..."
$SIMCTL terminate "$PHONE_UDID" "$APP_BUNDLE_ID" >/dev/null 2>&1 || true
$SIMCTL uninstall "$PHONE_UDID" "$APP_BUNDLE_ID" >/dev/null 2>&1 || true
$SIMCTL install "$PHONE_UDID" "$RUNNER_APP"
if [ "$DO_LAUNCH" = "1" ]; then
    echo "🚀 Launching on iPhone simulator..."
    $SIMCTL launch "$PHONE_UDID" "$APP_BUNDLE_ID"
fi

# --- Install & launch on watch -----------------------------------------------
if [ -n "${SKIP_WATCH:-}" ]; then
    echo ""
    echo "⚠️  Skipped watch install (no watch available)"
elif [ -d "$WATCH_APP" ]; then
    echo ""
    echo "📲 Installing on watch simulator..."
    $SIMCTL terminate "$WATCH_UDID" "$WATCH_BUNDLE_ID" >/dev/null 2>&1 || true
    $SIMCTL uninstall "$WATCH_UDID" "$WATCH_BUNDLE_ID" >/dev/null 2>&1 || true
    $SIMCTL install "$WATCH_UDID" "$WATCH_APP"
    if [ "$DO_LAUNCH" = "1" ]; then
        echo "🚀 Launching on watch simulator..."
        $SIMCTL launch "$WATCH_UDID" "$WATCH_BUNDLE_ID"
    fi
    echo ""
    echo "⌚ Watch app: installed & launched on $WATCH_UDID"
else
    echo "⚠️  WatchApp.app not found at $WATCH_APP"
fi

echo ""
echo "============================================"
echo "✅ Done! Look for 'Cipher Generator':"
echo "   - iPhone simulator (UDID $PHONE_UDID)"
if [ -n "${SKIP_WATCH:-}" ]; then
    echo "   - No watch simulator was available"
elif [ -n "$WATCH_UDID" ]; then
    echo "   - Watch simulator (UDID $WATCH_UDID)"
fi
echo ""
echo "💡 If you use Xcode directly: select the Runner scheme + iPhone destination,"
echo "   then Run. The watch app is embedded and installs on the paired watch."