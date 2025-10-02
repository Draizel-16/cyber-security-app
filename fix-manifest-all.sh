#!/bin/bash
echo "🚀 Auto Fix Manifest untuk Semua Activities"

MANIFEST="app/src/main/AndroidManifest.xml"

# Tambahkan LoginActivity
if ! grep -q "LoginActivity" "$MANIFEST"; then
  sed -i '/<\/application>/i \        <activity android:name=".ui.LoginActivity" android:exported="true" />' "$MANIFEST"
  echo "➕ Tambah LoginActivity ke Manifest"
fi

# Tambahkan DashboardActivity
if ! grep -q "DashboardActivity" "$MANIFEST"; then
  sed -i '/<\/application>/i \        <activity android:name=".ui.DashboardActivity" android:exported="true" />' "$MANIFEST"
  echo "➕ Tambah DashboardActivity ke Manifest"
fi

# Tambahkan PasswordGeneratorActivity
if ! grep -q "PasswordGeneratorActivity" "$MANIFEST"; then
  sed -i '/<\/application>/i \        <activity android:name=".ui.PasswordGeneratorActivity" android:exported="true" />' "$MANIFEST"
  echo "➕ Tambah PasswordGeneratorActivity ke Manifest"
fi

# Tambahkan EncryptActivity
if ! grep -q "EncryptActivity" "$MANIFEST"; then
  sed -i '/<\/application>/i \        <activity android:name=".ui.EncryptActivity" android:exported="true" />' "$MANIFEST"
  echo "➕ Tambah EncryptActivity ke Manifest"
fi

# Commit & Push
git add "$MANIFEST"
git commit -m "fix: ensure all Activities added to AndroidManifest"
git push origin main

echo "✅ Semua Activities sudah dipastikan ada di AndroidManifest.xml"
