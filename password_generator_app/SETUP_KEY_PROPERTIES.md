# 🔑 Setting Up key.properties - Step by Step

## The Problem

Your AAB is being signed with a debug key (SHA1: `D6:A5:93:55:28:43:39:9B:4E:DA:FB:4B:1D:44:F1:32:5B:72:DD:CB`), but Google Play expects the original key (SHA1: `10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB`).

## Solution: Create key.properties File

### Step 1: Find Your Original Keystore

You need to find the `.jks` or `.keystore` file that was used for the first upload.

**Search for it:**
```bash
find ~ -name "*.jks" -o -name "*.keystore"
```

**Common locations:**
- `~/upload-keystore.jks`
- `~/android/app/upload-keystore.jks`
- `~/keystore.jks`
- `~/Documents/` or `~/Downloads/`

### Step 2: Verify the Keystore

Once you find a keystore, verify it matches:

```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
./verify_keystore.sh /path/to/your/keystore.jks upload
```

Replace:
- `/path/to/your/keystore.jks` with your actual keystore path
- `upload` with your actual alias name (common aliases: `upload`, `key`, `release`)

**If it matches**, you'll see: ✅ MATCH!

### Step 3: Create key.properties

1. **Copy the example file:**
   ```bash
   cd ~/Developer/Random-Password-Generator/password_generator_app/android
   cp key.properties.example key.properties
   ```

2. **Edit `key.properties`** with your details:
   ```properties
   storeFile=/home/ionutcipriananescu/path/to/your/keystore.jks
   storePassword=your_actual_password
   keyAlias=your_actual_alias
   keyPassword=your_actual_password
   ```

   **Important:**
   - Use **absolute path** (full path starting with `/`)
   - Use the **actual password** for your keystore
   - Use the **actual alias** name (often `upload` or `key`)

### Step 4: Rebuild AAB

```bash
cd ~/Developer/Random-Password-Generator/password_generator_app
flutter clean
flutter build appbundle --release
```

### Step 5: Verify the New AAB

Check the new AAB is signed correctly:

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab | grep -i SHA1
```

You should see: `SHA1: 10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB`

## Example key.properties File

```properties
storeFile=/home/ionutcipriananescu/upload-keystore.jks
storePassword=MySecurePassword123
keyAlias=upload
keyPassword=MySecurePassword123
```

## If You Can't Find the Keystore

If you've lost the original keystore:

1. **Contact Google Play Support:**
   - Go to [Google Play Console](https://play.google.com/console)
   - Help → Contact Us
   - Explain you lost your signing key
   - They may be able to help (requires verification)

2. **Alternative:** Create a new app listing with a new keystore

## Security Notes

- ⚠️ **Never commit `key.properties` to git!**
- The file is already in `.gitignore`
- Keep your keystore and passwords secure
- Back up your keystore file!

## Troubleshooting

### "storeFile not found"
- Use absolute path (starting with `/`)
- Check the file exists: `ls -la /path/to/keystore.jks`

### "Wrong password"
- Double-check your keystore password
- Try listing aliases: `keytool -list -keystore /path/to/keystore.jks`

### "Wrong alias"
- List aliases: `keytool -list -keystore /path/to/keystore.jks`
- Common aliases: `upload`, `key`, `release`, `androidkey`

---

**After setting up key.properties correctly, rebuild and upload! 🚀**

