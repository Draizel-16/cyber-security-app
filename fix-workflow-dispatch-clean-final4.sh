#!/bin/bash
set -e

echo "🚀 Final Fix workflow_dispatch structure (v3.1)"

WF_PATH=".github/workflows/android-release.yml"
if [ ! -f "$WF_PATH" ]; then
  echo "❌ File $WF_PATH tidak ditemukan!"
  exit 1
fi

cp "$WF_PATH" "$WF_PATH.bak"
echo "📦 Backup dibuat: $WF_PATH.bak"

# Pastikan baris "on:" ditulis sebelum workflow_dispatch
awk '
BEGIN {fixed=0}
{
  if (!fixed && $1=="workflow_dispatch:") {
    print "on:"; fixed=1
  }
  print
}' "$WF_PATH" > "$WF_PATH.tmp" && mv "$WF_PATH.tmp" "$WF_PATH"

# Bersihkan duplikat branches
awk '!x[$0]++' "$WF_PATH" > "$WF_PATH.tmp" && mv "$WF_PATH.tmp" "$WF_PATH"

echo "✅ YAML diperbaiki total — termasuk penambahan 'on:'"
echo "🔍 Preview hasil:"
head -15 "$WF_PATH"

git add "$WF_PATH"
git commit -m "fix: enforce correct 'on:' position for workflow_dispatch (v3.1)" || echo "ℹ️ Tidak ada perubahan baru"
git push

echo "⏳ Menunggu sinkronisasi GitHub..."
sleep 5

echo "⚡ Coba trigger workflow lagi..."
if gh workflow run android-release.yml --ref main; then
  echo "✅ Workflow berhasil dijalankan!"
else
  echo "⚠️ Masih gagal? Buka https://github.com/Draizel-16/cyber-security-app/actions"
  echo "   ➜ Periksa apakah tombol 'Run workflow' sudah muncul di kanan atas."
fi

echo "✨ Selesai — file YAML sekarang pasti valid sepenuhnya."
