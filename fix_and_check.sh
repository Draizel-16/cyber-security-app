#!/bin/bash
set -e

echo "=== 🚀 Fix AndroidX & Cek Build Otomatis ==="

# Pastikan gradle.properties ada
if [ ! -f gradle.properties ]; then
  echo "❌ File gradle.properties tidak ditemukan!"
  exit 1
fi

# Tambahkan properti AndroidX jika belum ada
grep -q "android.useAndroidX=true" gradle.properties || echo "android.useAndroidX=true" >> gradle.properties
grep -q "android.enableJetifier=true" gradle.properties || echo "android.enableJetifier=true" >> gradle.properties

echo "=== gradle.properties sekarang ==="
cat gradle.properties
echo "================================="

# Konfigurasi Git (supaya tidak error identity unknown)
git config user.email "draizel16@example.com"
git config user.name "Draizel"

# Commit perubahan jika ada
if [[ -n $(git status --porcelain | grep gradle.properties) ]]; then
  echo "💾 Ada perubahan di gradle.properties → commit & push"
  git add gradle.properties
  git commit -m "fix: enable AndroidX + Jetifier"
  git push origin main
else
  echo "⚠️ Tidak ada perubahan di gradle.properties → skip commit"
fi

# Ambil run terakhir
RUN_ID=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada workflow run ditemukan"
  exit 1
fi

# Rerun workflow terakhir
echo "🔄 Menjalankan ulang workflow terakhir ID: $RUN_ID..."
gh run rerun $RUN_ID
sleep 5

# Tunggu sampai workflow selesai
STATUS=$(gh run view $RUN_ID --json status -q '.status')
while [ "$STATUS" == "in_progress" ] || [ "$STATUS" == "queued" ]; do
  echo "⏳ Workflow masih $STATUS... tunggu 20 detik"
  sleep 20
  STATUS=$(gh run view $RUN_ID --json status -q '.status')
done

echo "✅ Workflow selesai dengan status: $STATUS"

# Simpan log error terakhir
gh run view $RUN_ID --log-failed > last_error.log || true

echo "=== ERROR TERDETEKSI ==="
grep -i "FAILURE\|FAILED\|error" last_error.log || echo "⚠️ Tidak ada error ditemukan"

echo "======================================"
echo "📄 Log lengkap tersimpan di: last_error.log"
echo
echo "👀 Membuka log dengan less..."
sleep 2
less last_error.log
