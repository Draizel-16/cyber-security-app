#!/bin/bash
set -e

cd ~/cyber-security-app

echo "=== Update gradle.properties ==="
# Tambahkan AndroidX + Jetifier jika belum ada
grep -qxF "android.useAndroidX=true" gradle.properties || echo "android.useAndroidX=true" >> gradle.properties
grep -qxF "android.enableJetifier=true" gradle.properties || echo "android.enableJetifier=true" >> gradle.properties

echo "=== gradle.properties sekarang ==="
cat gradle.properties
echo "================================="

# Commit & push
git add gradle.properties
git commit -m "fix: enable AndroidX + Jetifier" || echo "⚠️ Tidak ada perubahan untuk commit"
git push origin main

# Ambil run ID terakhir di branch main
echo "🔍 Ambil workflow run terakhir..."
cd ~/cyber-security-app && \

# Ambil log build terakhir (ganti RUN_ID sesuai yang terbaru)
RUN_ID=17891394724 && \
gh run view $RUN_ID --log > last_build.log && \

# Cari error
grep -i -E "error|fail|exception" last_build.log > errors.log || true && \

# Kalau ada error, tampilkan. Kalau kosong, tampilkan 50 baris terakhir log
if [ -s errors.log ]; then
  echo "=== ERROR TERDETEKSI ==="
  cat errors.log
else
  echo "=== ERROR TIDAK KETEMU, CETAK 50 BARIS TERAKHIR LOG ==="
  tail -n 50 last_build.log
fi
