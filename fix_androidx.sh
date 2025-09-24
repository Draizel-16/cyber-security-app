#!/bin/bash
set -e

echo "=== Fix AndroidX Build Error ==="

# 1. Pastikan gradle.properties ada
if [ ! -f gradle.properties ]; then
  echo "gradle.properties tidak ditemukan, membuat baru..."
  touch gradle.properties
fi

# 2. Tambahkan android.useAndroidX & android.enableJetifier kalau belum ada
grep -q "android.useAndroidX" gradle.properties || echo "android.useAndroidX=true" >> gradle.properties
grep -q "android.enableJetifier" gradle.properties || echo "android.enableJetifier=true" >> gradle.properties

echo "=== gradle.properties sekarang ==="
cat gradle.properties
echo "================================="

# 3. Commit & push
git add gradle.properties

# Set identitas git kalau belum ada
git config user.email || git config --global user.email "ci-bot@example.com"
git config user.name  || git config --global user.name "CI Bot"

git commit -m "Fix: enable AndroidX support" || echo "⚠️ Tidak ada perubahan untuk commit"
git push origin main

# 4. Trigger ulang build (workflow terakhir)
echo "🔄 Menjalankan ulang workflow terakhir..."
gh run rerun $(gh run list --limit 1 --json databaseId -q '.[0].databaseId')

echo "✅ Selesai. Cek hasil build di GitHub Actions."
