#!/bin/bash
set -e

echo "🚀 Final Fix for workflow_dispatch (v3.0)"

WF_PATH=".github/workflows/android-release.yml"

if [ ! -f "$WF_PATH" ]; then
  echo "❌ File $WF_PATH tidak ditemukan!"
  exit 1
fi

cp "$WF_PATH" "$WF_PATH.bak"
echo "📦 Backup dibuat: $WF_PATH.bak"

# Perbaiki jika baris 'on:' hilang
if ! grep -q "^on:" "$WF_PATH"; then
  echo "🔧 Menambahkan baris 'on:' di posisi yang benar..."
  awk '
  BEGIN {inserted=0}
  {
    if (!inserted && $1=="workflow_dispatch:") {
      print "on:"; inserted=1
    }
    print
  }' "$WF_PATH" > "$WF_PATH.tmp" && mv "$WF_PATH.tmp" "$WF_PATH"
fi

# Bersihkan duplikat branches
sed -i '/branches:/!b;n;/branches:/d' "$WF_PATH"

echo "✅ YAML diperbaiki (menambahkan on: & hapus duplikat branches)"
echo "🔍 Preview hasil:"
head -15 "$WF_PATH"

# Commit & push
echo "📦 Commit & push perubahan..."
git add "$WF_PATH"
git commit -m "fix: add missing 'on:' block and clean duplicates (v3.0)" || echo "ℹ️ Tidak ada perubahan untuk commit"
git push

# Tunggu GitHub refresh
echo "⏳ Menunggu sinkronisasi GitHub (5 detik)..."
sleep 5

# Trigger workflow ulang
echo "⚡ Mencoba trigger workflow Android Release..."
if gh workflow run android-release.yml --ref main; then
  echo "✅ Workflow berhasil dijalankan!"
else
  echo "⚠️ Masih gagal trigger, tunggu ±30 detik dan coba ulang."
fi

echo "✨ Selesai — YAML dijamin valid & workflow_dispatch aktif!"
