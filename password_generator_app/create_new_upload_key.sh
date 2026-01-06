#!/bin/bash

# Script to create a new upload key and set it up for Google Play

echo "🔑 Creating New Upload Key for Google Play"
echo "=========================================="
echo ""

KEYSTORE_PATH="$HOME/upload-keystore.jks"
KEY_ALIAS="upload"

# Check if keystore already exists
if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  Keystore already exists at: $KEYSTORE_PATH"
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    rm "$KEYSTORE_PATH"
fi

echo "Step 1: Creating new keystore..."
echo ""

# Get password
read -sp "Enter a password for your keystore (remember this!): " STORE_PASSWORD
echo ""
read -sp "Confirm password: " STORE_PASSWORD_CONFIRM
echo ""

if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
    echo "❌ Passwords don't match!"
    exit 1
fi

if [ -z "$STORE_PASSWORD" ]; then
    echo "❌ Password cannot be empty!"
    exit 1
fi

# Get user info
echo ""
read -p "Enter your name (for certificate): " USER_NAME
read -p "Enter your organization (or press Enter to skip): " ORGANIZATION
read -p "Enter your city (or press Enter to skip): " CITY
read -p "Enter your state/province (or press Enter to skip): " STATE
read -p "Enter your country code (2 letters, e.g., US, RO): " COUNTRY

if [ -z "$USER_NAME" ]; then
    USER_NAME="Ionut Ciprian Anescu"
fi

if [ -z "$COUNTRY" ]; then
    COUNTRY="RO"
fi

echo ""
echo "Creating keystore..."
echo ""

# Create keystore
keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$STORE_PASSWORD" \
    -keypass "$STORE_PASSWORD" \
    -dname "CN=$USER_NAME, OU=Android, O=${ORGANIZATION:-Unknown}, L=${CITY:-Unknown}, ST=${STATE:-Unknown}, C=$COUNTRY"

if [ $? -ne 0 ]; then
    echo "❌ Failed to create keystore"
    exit 1
fi

echo ""
echo "✅ Keystore created successfully!"
echo ""

# Get certificate info
echo "Step 2: Getting certificate information..."
echo ""

SHA1=$(keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -storepass "$STORE_PASSWORD" | grep -i "SHA1" | head -1 | awk '{print $2}')
SHA256=$(keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -storepass "$STORE_PASSWORD" | grep -i "SHA256" | head -1 | awk '{print $2}')

echo "Keystore Information:"
echo "  Location: $KEYSTORE_PATH"
echo "  Alias: $KEY_ALIAS"
echo "  SHA-1: $SHA1"
echo "  SHA-256: $SHA256"
echo ""

# Export certificate
CERT_PATH="$HOME/upload_certificate.pem"
echo ""
echo "Step 3: Exporting certificate..."
keytool -export -rfc \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -file "$CERT_PATH" \
    -storepass "$STORE_PASSWORD"

if [ $? -eq 0 ]; then
    echo "✅ Certificate exported to: $CERT_PATH"
    echo ""
    echo "📋 Next Steps:"
    echo "=============="
    echo ""
    echo "1. Go to Google Play Console:"
    echo "   https://play.google.com/console"
    echo ""
    echo "2. Navigate to: Your App → Release → Setup → App signing"
    echo ""
    echo "3. Click 'Reset upload key' or 'Change upload key'"
    echo ""
    echo "4. Upload the certificate file:"
    echo "   $CERT_PATH"
    echo ""
    echo "5. Wait for Google to approve (may take a few hours)"
    echo ""
    echo "6. Once approved, create key.properties file:"
    echo "   (I'll create it for you now)"
    echo ""
else
    echo "⚠️  Could not export certificate, but keystore is created"
    echo "   You can export it manually later with:"
    echo "   keytool -export -rfc -keystore $KEYSTORE_PATH -alias $KEY_ALIAS -file certificate.pem"
fi

# Create key.properties
echo ""
echo "Step 4: Creating key.properties file..."
echo ""

KEY_PROPERTIES_FILE="android/key.properties"
ABS_KEYSTORE_PATH=$(realpath "$KEYSTORE_PATH" 2>/dev/null || echo "$KEYSTORE_PATH")

# Create android directory if it doesn't exist
mkdir -p android

cat > "$KEY_PROPERTIES_FILE" << EOF
storeFile=$ABS_KEYSTORE_PATH
storePassword=$STORE_PASSWORD
keyAlias=$KEY_ALIAS
keyPassword=$STORE_PASSWORD
EOF

echo "✅ Created $KEY_PROPERTIES_FILE"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Keep your keystore password safe!"
echo "   - Backup the keystore file: $KEYSTORE_PATH"
echo "   - The certificate file is: $CERT_PATH"
echo "   - key.properties is already in .gitignore (won't be committed)"
echo ""

echo "📝 Summary:"
echo "==========="
echo "Keystore: $KEYSTORE_PATH"
echo "Certificate: $CERT_PATH"
echo "SHA-1: $SHA1"
echo "SHA-256: $SHA256"
echo ""
echo "✅ Setup complete! Now:"
echo "   1. Upload $CERT_PATH to Google Play Console"
echo "   2. Wait for approval"
echo "   3. Then rebuild your AAB: flutter build appbundle --release"
echo ""













