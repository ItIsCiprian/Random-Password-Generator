# 🚀 Quick Start Guide - Test on Your Phone

## Step 1: Prepare Your Phone

1. **Enable Developer Options:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - You'll see "You are now a developer!"

2. **Enable USB Debugging:**
   - Go to Settings → Developer Options
   - Turn on "USB Debugging"
   - Accept the warning

3. **Connect Phone to Computer:**
   - Use a USB cable
   - On your phone, when prompted, allow USB debugging
   - Check "Always allow from this computer" if you want

## Step 2: Install Dependencies

Open terminal in the `password_generator_app` folder and run:

```bash
flutter pub get
```

## Step 3: Check Connection

```bash
flutter devices
```

You should see your phone listed. If not:
- Try a different USB cable
- Check if USB debugging is enabled
- Try `adb devices` to test ADB connection

## Step 4: Build and Install

### Option A: Direct Install (Easiest)
```bash
flutter run
```

This will:
- Build the app
- Install it on your phone
- Launch it automatically

### Option B: Build APK First
```bash
flutter build apk
```

Then find the APK at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer to your phone and install manually.

### Option C: Use the Build Script
```bash
./build_and_install.sh
```

## Step 5: Test the App

Once installed, test these features:

1. ✅ Generate a password
2. ✅ Check the strength meter (should show color and percentage)
3. ✅ Copy password to clipboard
4. ✅ Generate more passwords (check history appears)
5. ✅ Toggle light/dark mode
6. ✅ View info modal

## Troubleshooting

### "No devices found"
- Make sure USB debugging is enabled
- Try `adb devices` to check ADB
- Unplug and replug USB cable
- Restart ADB: `adb kill-server && adb start-server`

### "Build failed"
- Run `flutter clean`
- Run `flutter pub get`
- Check `flutter doctor` for issues

### "App crashes"
- Check Android version (needs 5.0+)
- Clear app data: Settings → Apps → Cipher Generator → Clear Data
- Reinstall the app

### "Permission denied" (Linux)
You may need to add udev rules for your device. Check Flutter documentation for your specific device.

## What to Test

- [ ] Password generation works
- [ ] Strength meter shows correctly
- [ ] Copy button works
- [ ] Password history saves
- [ ] Light mode looks good
- [ ] Dark mode looks good
- [ ] Theme toggle works
- [ ] Info modal opens
- [ ] App doesn't crash
- [ ] UI is responsive on your phone

## Need Help?

Check `BUILD_INSTRUCTIONS.md` for detailed instructions.

---

**Ready to test! 🎉**

