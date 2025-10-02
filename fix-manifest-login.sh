#!/bin/bash
echo "🚀 Auto Fix Manifest untuk LoginActivity"

MANIFEST="app/src/main/AndroidManifest.xml"
ACTIVITY_ENTRY='<activity android:name=".ui.LoginActivity" />'

# Cek apakah sudah ada
if grep -q 'LoginActivity' "$MANIFEST"; then
  echo "ℹ️ LoginActivity sudah ada di AndroidManifest.xml"
else
  echo "➕ Tambah LoginActivity ke AndroidManifest.xml"
  # Sisipkan sebelum </application>
  sed -i "/<\/application>/i \        $ACTIVITY_ENTRY" "$MANIFEST"
fi

# Commit & push
echo "📦 Commit & Push..."
git add "$MANIFEST"
git commit -m "fix: add LoginActivity to AndroidManifest"
git push origin main

echo "✅ LoginActivity sudah dipastikan ada di AndroidManifest.xml"
