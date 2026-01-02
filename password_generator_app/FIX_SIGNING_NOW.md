# 🚨 Fix Signing Issue - Quick Guide

## The Problem

Your AAB is signed with the **debug key** (SHA1: `D6:A5:93:55:28:43:39:9B:4E:DA:FB:4B:1D:44:F1:32:5B:72:DD:CB`), but Google Play expects your **original key** (SHA1: `10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB`).

## Quick Fix - Interactive Setup

Run this script - it will guide you through the process:

```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
./setup_signing_interactive.sh
```

This script will:
1. ✅ Search for your keystore files
2. ✅ Let you select the correct one
3. ✅ Verify the fingerprint matches
4. ✅ Create `key.properties` file
5. ✅ Rebuild the AAB with correct signing
6. ✅ Verify the new signature

## Manual Setup (If Script Doesn't Work)

### Step 1: Find Your Keystore

You need the `.jks` file that was used for the first Play Store upload.

```bash
# Search for keystores
find ~ -name "*.jks" -o -name "*.keystore"
```

**Check common locations:**
- `~/upload-keystore.jks`
- `~/keystore.jks`
- `~/Documents/`
- `~/Downloads/`
- Any backup folders

### Step 2: Verify It's the Right One

```bash
./verify_keystore.sh /path/to/keystore.jks upload
```

It should show: ✅ MATCH!

### Step 3: Create key.properties

```bash
cd android
cp key.properties.example key.properties
nano key.properties
```

Fill in:
```properties
storeFile=/full/absolute/path/to/your/keystore.jks
storePassword=your_password
keyAlias=your_alias
keyPassword=your_password
```

**Use absolute path!** Example:
```properties
storeFile=/home/ionutcipriananescu/upload-keystore.jks
storePassword=MyPassword123
keyAlias=upload
keyPassword=MyPassword123
```

### Step 4: Rebuild

```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
flutter clean
flutter build appbundle --release
```

### Step 5: Verify

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab | grep SHA1
```

Should show: `SHA1: 10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB`

## If You Lost the Keystore

⚠️ **You cannot upload without the original keystore!**

**Option 1: Contact Google Play Support**
1. Go to [Play Console](https://play.google.com/console)
2. Help → Contact Us
3. Explain you lost your signing key
4. They may help reset it (requires verification)

**Option 2: Create New App**
- Create a new app listing
- Use a new keystore
- Users will need to download the new app

## Common Issues

### "storeFile not found"
- Use **absolute path** starting with `/`
- Check file exists: `ls -la /path/to/keystore.jks`

### "Wrong password"
- Double-check your keystore password
- Try: `keytool -list -keystore /path/to/keystore.jks`

### "Wrong alias"
- List aliases: `keytool -list -keystore /path/to/keystore.jks`
- Common: `upload`, `key`, `release`

---

**Run the interactive script to fix it automatically! 🚀**

