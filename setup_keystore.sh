#!/bin/bash
set -e

# Nama repo GitHub (ganti sesuai user/repo kamu)
REPO="Draizel-16/cyber-security-app"

# Nama file keystore
KEYSTORE="release.keystore"

echo "🔑 Membuat keystore baru..."
keytool -genkeypair \
  -v \
  -keystore $KEYSTORE \
  -alias myalias \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass mystorepass \
  -keypass mykeypass \
  -dname "CN=example, OU=Dev, O=Company, L=City, S=State, C=ID"

echo "📦 Encode keystore ke base64..."
base64 $KEYSTORE > release.keystore.b64

echo "🚀 Upload ke GitHub Secrets..."
gh secret set SIGNING_KEY -R $REPO < release.keystore.b64
gh secret set ALIAS -R $REPO -b"myalias"
gh secret set KEY_STORE_PASSWORD -R $REPO -b"mystorepass"
gh secret set KEY_PASSWORD -R $REPO -b"mykeypass"

echo "✅ Semua secrets sudah diset di repo $REPO"
