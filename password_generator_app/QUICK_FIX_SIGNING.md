# 🔐 Quick Fix: Signing Key Issue

## Problem

Your AAB is signed with the wrong key. Google Play expects:
```
SHA1: 10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB
```

But your AAB has:
```
SHA1: D6:A5:93:55:28:43:39:9B:4E:DA:FB:4B:1D:44:F1:32:5B:72:DD:CB
```

## Quick Solution

### Step 1: Find Your Original Keystore

Run the helper script:
```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
./find_keystore.sh
```

Or search manually:
```bash
find ~ -name "*.jks" -o -name "*.keystore"
```

### Step 2: Create key.properties

1. **Copy the example:**
   ```bash
   cd android
   cp key.properties.example key.properties
   ```

2. **Edit `android/key.properties`** with your keystore info:
   ```properties
   storeFile=/full/path/to/your/keystore.jks
   storePassword=your_password
   keyAlias=your_alias
   keyPassword=your_password
   ```

   **Important:** Use absolute path to keystore file.

### Step 3: Verify Fingerprint

Check if it matches:
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your_alias
```

Look for SHA1: `10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB`

### Step 4: Rebuild AAB

```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
flutter clean
flutter build appbundle --release
```

### Step 5: Verify New AAB

Check the new AAB's signature:
```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

Or use:
```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

## If You Don't Have the Original Keystore

⚠️ **You cannot upload to the same app without the original key!**

### Option 1: Contact Google Play Support (Recommended)

1. Go to [Google Play Console](https://play.google.com/console)
2. Help → Contact Us
3. Explain you lost your signing key
4. They may be able to help reset it (requires verification)

### Option 2: Create New App

If you can't recover the key:
1. Create a new app in Play Console
2. Use a new keystore
3. Users will need to download the new app

## Security Reminder

- ⚠️ **Never commit `key.properties` to git!**
- Keep your keystore backed up securely
- Store passwords in a password manager

---

**After setting up key.properties, rebuild and upload! 🚀**

