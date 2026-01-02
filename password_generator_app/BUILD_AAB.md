# 📦 Building AAB (Android App Bundle) File

## What is an AAB file?

**AAB (Android App Bundle)** is the publishing format required by Google Play Store. It's optimized for distribution and allows Google Play to generate optimized APKs for different device configurations.

## Build AAB File

### Quick Build

```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
flutter build appbundle --release
```

### Build Both APK and AAB

Use the provided script to build both:

```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
./build_all.sh
```

Or build manually:

```bash
# Build APK
flutter build apk --release

# Build AAB
flutter build appbundle --release
```

## Output Locations

After building:

- **APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **AAB:** `build/app/outputs/bundle/release/app-release.aab`

## Using the AAB File

### For Google Play Store

1. **Go to Google Play Console:**
   - https://play.google.com/console

2. **Create or select your app**

3. **Upload the AAB:**
   - Go to "Production" → "Create new release"
   - Upload `app-release.aab`
   - Fill in release notes
   - Submit for review

### Important Notes

- ⚠️ **AAB files cannot be installed directly on devices**
- ✅ Use APK for direct installation/testing
- ✅ Use AAB for Play Store distribution
- 📦 AAB files are typically smaller than APKs
- 🎯 Google Play generates optimized APKs from AAB

## File Sizes

- **APK:** Usually larger (includes all architectures)
- **AAB:** Usually smaller (Play Store generates optimized APKs)

## Troubleshooting

### Build fails with signing error?

The current configuration uses debug signing. For Play Store, you'll need a proper release keystore:

1. Create a keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties`:
   ```
   storePassword=your_password
   keyPassword=your_password
   keyAlias=upload
   storeFile=/path/to/upload-keystore.jks
   ```

3. The build.gradle is already configured to use it if it exists.

### AAB file not found?

Check the output directory:
```bash
ls -lh build/app/outputs/bundle/release/
```

---

**Ready to publish! 🚀**

