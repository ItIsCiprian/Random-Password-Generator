# 🚀 Build the App Now!

## Quick Build Instructions

Since Flutter might not be in your PATH, here are the steps to build:

### Step 1: Find Flutter

First, locate your Flutter installation. Common locations:
- `~/flutter/bin/flutter`
- `~/snap/flutter/common/flutter/bin/flutter`
- `/opt/flutter/bin/flutter`
- Or check if you have it installed via package manager

### Step 2: Build the APK

**Option A: If Flutter is in PATH**
```bash
cd Random-Password-Generator/password_generator_app
flutter pub get
flutter build apk
```

**Option B: Using full path to Flutter**
```bash
cd Random-Password-Generator/password_generator_app
~/flutter/bin/flutter pub get
~/flutter/bin/flutter build apk
```

**Option C: Use the build script**
```bash
cd Random-Password-Generator/password_generator_app
./build_apk.sh
```

### Step 3: Find Your APK

After building, the APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Install on Phone

1. **Transfer APK to phone:**
   - Via USB: Copy the APK file to your phone
   - Via email: Email the APK to yourself
   - Via cloud: Upload to Google Drive/Dropbox

2. **Enable Unknown Sources:**
   - Settings → Security → Enable "Install from Unknown Sources"
   - Or Settings → Apps → Special Access → Install Unknown Apps

3. **Install:**
   - Open the APK file on your phone
   - Tap "Install"
   - Wait for installation to complete

4. **Launch:**
   - Find "Cipher Generator" in your app drawer
   - Tap to open and start using!

## Alternative: Build and Install Directly

If your phone is connected via USB:

```bash
cd Random-Password-Generator/password_generator_app
flutter pub get
flutter run --release
```

This will build and install directly to your connected device.

## Troubleshooting

### "flutter: command not found"
- Add Flutter to your PATH, or
- Use the full path: `~/flutter/bin/flutter build apk`

### Build errors
- Run `flutter clean` first
- Make sure you have Android SDK installed
- Check `flutter doctor` for issues

### APK not found
- Check `build/app/outputs/flutter-apk/` directory
- Look for `app-release.apk` or `app-debug.apk`

---

**Ready to build! 🎉**

