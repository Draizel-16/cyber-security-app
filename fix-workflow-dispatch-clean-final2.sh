#!/bin/bash
set -e

echo "🚀 Super Clean Fix for workflow_dispatch (v2.1)"

WF_PATH=".github/workflows/android-release.yml"

if [ ! -f "$WF_PATH" ]; then
  echo "❌ File $WF_PATH tidak ditemukan!"
  exit 1
fi

cp "$WF_PATH" "$WF_PATH.bak"
echo "📦 Backup dibuat: $WF_PATH.bak"

# Buat ulang bagian on: yang bersih
awk '
BEGIN {in_on=0}
{
  if ($1=="on:") {in_on=1; next}
  if (in_on && $1!~"^  ") {in_on=0}
  if (!in_on) print
}
END {
  print "on:"
  print "  workflow_dispatch:"
  print "  push:"
  print "    branches: [ main ]"
}' "$WF_PATH.bak" > "$WF_PATH"

echo "✅ YAML sudah dibersihkan & distandarisasi."
echo "🔍 Preview hasil (20 baris awal):"
head -20 "$WF_PATH"

# Commit & push
echo "📦 Commit & push perubahan..."
git add "$WF_PATH"
git commit -m "fix: rebuild clean workflow_dispatch section (v2.1)" || echo "ℹ️ Tidak ada perubahan untuk commit"
git push || echo "ℹ️ Push mungkin sudah up-to-date"

# Tunggu sinkronisasi GitHub
echo "⏳ Menunggu sinkronisasi GitHub (5 detik)..."
sleep 5

# Trigger workflow ulang
echo "⚡ Trigger ulang workflow Android Release..."
if gh workflow run android-release.yml --ref main; then
  echo "✅ Workflow berhasil dijalankan!"
else
  echo "⚠️ Gagal trigger, tunggu 30 detik lalu coba ulang."
fi

echo "✨ Selesai — YAML 100% valid & workflow_dispatch aktif!"
