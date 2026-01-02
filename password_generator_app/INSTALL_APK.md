# 📱 How to Install the APK on Your Phone

## After Building the APK

Once you have the APK file (`app-release.apk`), follow these steps:

### Method 1: USB Transfer (Easiest)

1. **Connect phone to computer via USB**
2. **Copy APK to phone:**
   ```bash
   # On Linux/Mac
   cp build/app/outputs/flutter-apk/app-release.apk /path/to/phone/
   
   # Or use file manager to drag and drop
   ```
3. **On your phone:**
   - Open Files/File Manager app
   - Navigate to the APK location
   - Tap the APK file
   - Tap "Install"

### Method 2: Email/Cloud Transfer

1. **Upload APK to cloud storage** (Google Drive, Dropbox, etc.)
2. **Or email it to yourself**
3. **On your phone:**
   - Download the APK from email/cloud
   - Open the downloaded file
   - Tap "Install"

### Method 3: ADB Install (Advanced)

If you have ADB installed and phone connected:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Enable Installation from Unknown Sources

Before installing, you may need to enable "Install from Unknown Sources":

### Android 8.0+ (Oreo and newer):
1. Go to **Settings → Apps → Special Access → Install Unknown Apps**
2. Select your file manager or browser
3. Enable "Allow from this source"

### Older Android versions:
1. Go to **Settings → Security**
2. Enable **"Unknown Sources"** or **"Install Unknown Apps"**

## After Installation

1. **Find the app:**
   - Look for "Cipher Generator" in your app drawer
   - Icon should be visible

2. **Launch and test:**
   - Open the app
   - Generate a password
   - Check all features work

3. **If app doesn't appear:**
   - Check Settings → Apps → Cipher Generator
   - Make sure it's installed
   - Try restarting your phone

## Uninstall (if needed)

To remove the app:
- Settings → Apps → Cipher Generator → Uninstall

---

**Enjoy your password generator! 🔐**

