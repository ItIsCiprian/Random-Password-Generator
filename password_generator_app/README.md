# 🔐 Cipher Generator

A modern, feature-rich password generator Flutter app with password strength meter, history tracking, and beautiful UI.

## ✨ Features

- 🎲 **Customizable Password Generation**
  - Adjustable length (4-32 characters)
  - Toggle lowercase, uppercase, digits, and special characters
  - Secure random generation

- 📊 **Password Strength Meter**
  - Visual strength indicator with color coding
  - Percentage display
  - Real-time strength calculation

- 📜 **Password History**
  - Stores up to 50 recently generated passwords
  - Quick copy from history
  - Persistent storage

- 🎨 **Beautiful UI**
  - Light and Dark mode support
  - Color-coded passwords by strength
  - Modern Material Design
  - Responsive layout

- 📋 **Easy Copy**
  - One-tap copy to clipboard
  - Visual feedback
  - Copy from history

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.4.1 or higher)
- Android Studio / Android SDK
- Android device with USB debugging enabled OR Android emulator

### Installation

1. **Install dependencies:**
   ```bash
   cd password_generator_app
   flutter pub get
   ```

2. **Connect your Android device** via USB and enable USB debugging

3. **Run the app:**
   ```bash
   flutter run
   ```

   Or use the build script:
   ```bash
   ./build_and_install.sh
   ```

### Build APK for Manual Installation

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Build AAB for Google Play Store

```bash
flutter build appbundle --release
```

The AAB will be at: `build/app/outputs/bundle/release/app-release.aab`

### Build Both APK and AAB

Use the provided script:
```bash
./build_all.sh
```

Or see `BUILD_AAB.md` for detailed instructions.

## 📱 App Details

- **App Name:** Cipher Generator
- **Package:** com.cipherpasswordgenerator.app
- **Min Android:** 5.0 (API 21)
- **Target Android:** 15 (API 35)

## 🎯 Usage

1. **Generate Password:**
   - Adjust the length slider
   - Toggle character types (lowercase, uppercase, digits, special)
   - Tap "Generate Password"

2. **Check Strength:**
   - View the strength meter below the password
   - Colors indicate strength: Red (Weak) → Green (Strong)

3. **Copy Password:**
   - Tap the copy icon next to any password
   - Password is copied to clipboard

4. **View History:**
   - Scroll down to see recently generated passwords
   - Tap copy icon to copy any password from history
   - Tap "Clear" to remove all history

5. **Toggle Theme:**
   - Tap the sun/moon icon in the top right
   - Switch between light and dark mode

6. **View Info:**
   - Tap the info icon for app information
   - View license information

## 🛠️ Development

### Project Structure

```
lib/
  └── main.dart          # Main app code
android/                 # Android configuration
ios/                    # iOS configuration (if needed)
pubspec.yaml            # Dependencies
```

### Dependencies

- `shared_preferences` - For storing password history
- `url_launcher` - For opening GitHub links

## 📄 License

See LICENSE file for details.

## 👤 Author

**Ionut Ciprian Anescu**
- GitHub: [@ItIsCiprian](https://github.com/ItIsCiprian)

## 🐛 Troubleshooting

### Device not detected?
- Enable USB debugging on your phone
- Check USB cable connection
- Run `flutter devices` to verify

### Build errors?
- Run `flutter clean`
- Run `flutter pub get`
- Check `flutter doctor` for issues

### App crashes?
- Check Android version (needs 5.0+)
- Clear app data and reinstall
- Check logs with `flutter logs`

## 📝 Changelog

### Version 1.0.4+6
- ✅ Added password strength meter
- ✅ Added password history with persistent storage
- ✅ Improved UI with color-coded passwords
- ✅ Fixed light mode colors
- ✅ Better mobile layout and button placement
- ✅ Enhanced copy functionality

---

**Enjoy generating secure passwords! 🔐**
