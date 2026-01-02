# Build Instructions for Cipher Generator

## Prerequisites

1. **Flutter SDK** - Make sure Flutter is installed and in your PATH
   ```bash
   flutter --version
   ```

2. **Android Studio** or **Android SDK** - For building Android apps
   - Android SDK Platform 35
   - Android SDK Build-Tools
   - Android SDK Command-line Tools

3. **Enable USB Debugging** on your Android phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

## Quick Start

### Option 1: Build and Install via USB (Recommended)

1. **Connect your phone via USB** and enable USB debugging

2. **Check if device is detected:**
   ```bash
   cd password_generator_app
   flutter devices
   ```
   You should see your phone listed.

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run on your phone:**
   ```bash
   flutter run
   ```
   This will build and install the app on your connected phone.

### Option 2: Build APK for Manual Installation

1. **Build the APK:**
   ```bash
   cd password_generator_app
   flutter build apk
   ```

2. **Find the APK:**
   The APK will be located at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Transfer to your phone:**
   - Copy the APK to your phone via USB, email, or cloud storage
   - On your phone, enable "Install from Unknown Sources" in Settings
   - Open the APK file and install

### Option 3: Build App Bundle (for Play Store)

```bash
cd password_generator_app
flutter build appbundle
```

The AAB file will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

## Troubleshooting

### Device not detected?
- Make sure USB debugging is enabled
- Try different USB cable/port
- Run `adb devices` to check connection
- On Linux, you may need to add udev rules

### Build errors?
- Run `flutter clean`
- Run `flutter pub get`
- Check `flutter doctor` for issues

### Permission errors?
- Make sure you have write permissions in the project directory
- On Linux/Mac, you might need `sudo` for some operations

## Testing Features

Once installed, test these features:

1. ✅ **Password Generation** - Generate passwords with different settings
2. ✅ **Password Strength Meter** - Check strength indicator
3. ✅ **Password History** - View recently generated passwords
4. ✅ **Copy to Clipboard** - Test copy functionality
5. ✅ **Light/Dark Mode** - Toggle theme
6. ✅ **Info Modal** - View app information

## App Information

- **App Name:** Cipher Generator
- **Package:** com.cipherpasswordgenerator.app
- **Min Android Version:** 5.0 (API 21)
- **Target Android Version:** 15 (API 35)

