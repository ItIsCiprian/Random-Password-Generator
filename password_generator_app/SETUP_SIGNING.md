# 🔐 Setting Up App Signing for Google Play Store

## Problem

Your AAB is signed with the wrong key. Google Play Store requires you to use the **same signing key** for all uploads.

## Solution

You need to configure your app to use the correct signing key.

## Step 1: Locate Your Existing Keystore

If you've uploaded to Play Store before, you should have a keystore file (`.jks` or `.keystore`). Find it:

```bash
# Common locations:
# - ~/upload-keystore.jks
# - ~/android/app/upload-keystore.jks
# - ~/keystore.jks
# - Or wherever you saved it when creating the app

find ~ -name "*.jks" -o -name "*.keystore" 2>/dev/null
```

## Step 2: Create key.properties File

1. **Copy the example file:**
   ```bash
   cd ~/Developer/Random-Password-Generator/password_generator_app/android
   cp key.properties.example key.properties
   ```

2. **Edit `android/key.properties`** with your keystore details:
   ```properties
   storeFile=/path/to/your/keystore.jks
   storePassword=your_keystore_password
   keyAlias=your_key_alias
   keyPassword=your_key_password
   ```

   **Important:** Use absolute path or path relative to `android/` folder.

## Step 3: Verify Your Keystore Fingerprint

Check if your keystore matches the expected fingerprint:

```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your_key_alias
```

Look for the SHA1 fingerprint. It should match:
```
SHA1: 10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB
```

## Step 4: Rebuild AAB

After configuring `key.properties`, rebuild:

```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
flutter clean
flutter build appbundle --release
```

## If You Don't Have the Original Keystore

⚠️ **If you lost your original keystore**, you have two options:

### Option A: Contact Google Play Support (Recommended)

1. Go to Google Play Console
2. Contact support about key loss
3. They can help you reset the signing key
4. This may require creating a new app listing

### Option B: Create New Keystore (Requires New App)

If you can't recover the original key, you'll need to:
1. Create a new app in Play Console
2. Use a new keystore for that app

## Creating a New Keystore (If Needed)

If you need to create a new keystore:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Then update `android/key.properties` with the new keystore details.

## Security Notes

- ⚠️ **Never commit `key.properties` to git!**
- Add `android/key.properties` to `.gitignore`
- Keep your keystore file secure and backed up
- Never share your keystore password

## Current Configuration

The `build.gradle` is already configured to:
- Use `key.properties` if it exists
- Fall back to debug signing if no keystore is found

Once you create `key.properties` with the correct keystore, rebuild and upload again.

---

**After setting up, rebuild your AAB and upload to Play Store! 🚀**

