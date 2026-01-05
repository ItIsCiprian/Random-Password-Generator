# 📱 Google Play Console - Step by Step Guide

## Accessing App Signing Information

### Step-by-Step Navigation

1. **Login:**
   ```
   https://play.google.com/console
   ```

2. **Select Your App:**
   - Click on "Cipher Generator" from your app list

3. **Navigate to App Signing:**
   ```
   Left Sidebar → Release → Setup → App signing
   ```
   
   OR
   
   ```
   Left Sidebar → Release → Production → App signing
   ```

4. **What You'll See:**

   **App Signing Key Certificate** (Google's key - for users)
   - SHA-1: (different from yours)
   - SHA-256: 
   - Managed by Google

   **Upload Key Certificate** (Your key - for uploading)
   - SHA-1: `10:FD:4C:3C:29:B9:B4:87:11:30:0A:6F:EA:62:89:12:80:91:6E:FB`
   - This is what you need!

## Screenshots to Look For

Look for sections like:
- "Upload key certificate"
- "App signing key certificate" 
- "Certificate fingerprints"
- "Reset upload key" button (if available)

## If You See "Reset Upload Key" Option

1. Click **"Reset upload key"** or **"Request upload key reset"**
2. Follow the instructions
3. You'll need to:
   - Verify your identity
   - Create a new upload key
   - Upload the new certificate
   - Wait for Google approval

## If No Reset Option

Contact support directly from the App Signing page:
- Look for **"Contact support"** or **"Get help"** link
- Or use: Help → Contact Us → Publishing → App signing

---

**Check your Play Console now! 🚀**











