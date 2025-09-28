#!/bin/bash
# =========================================
# AUTO FIX MANIFEST & GRADLE (Android 12+)
# =========================================

set -e

MANIFEST="app/src/main/AndroidManifest.xml"
GRADLE="app/build.gradle"

echo "🔧 Memperbaiki $MANIFEST ..."

# 1. Hapus package="..." di tag <manifest>
sed -i 's/ package="[^"]*"//g' "$MANIFEST"

# 2. Tambahkan android:exported="true" di MainActivity jika belum ada
if ! grep -q 'android:exported=' "$MANIFEST"; then
  sed -i '/<activity[^>]*MainActivity/s/>/ android:exported="true">/' "$MANIFEST"
fi

echo "✅ AndroidManifest.xml sudah diperbaiki."

echo "🔧 Memperbaiki $GRADLE ..."

# 3. Tambahkan namespace di build.gradle kalau belum ada
if ! grep -q 'namespace ' "$GRADLE"; then
  sed -i '/android {/a\    namespace "com.example.cybersecurityapp"' "$GRADLE"
fi

echo "✅ build.gradle sudah diperbaiki."

# 4. Bersihkan dan build ulang
./gradlew clean assembleDebug || ./gradlew clean build

echo "🎉 Fix selesai! APK ada di app/build/outputs/apk/debug/"
