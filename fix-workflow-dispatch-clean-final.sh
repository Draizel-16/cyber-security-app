#!/bin/bash
set -e

echo "🚀 Final Auto Clean & Fix workflow_dispatch for android-release.yml"

WF_PATH=".github/workflows/android-release.yml"

if [ ! -f "$WF_PATH" ]; then
  echo "❌ File $WF_PATH tidak ditemukan!"
  exit 1
fi

cp "$WF_PATH" "$WF_PATH.bak"
echo "📦 Backup dibuat: $WF_PATH.bak"

# Bersihkan duplikat section `on:` dan normalize YAML
awk '
BEGIN {printed_on=0}
{
  # Skip duplikat workflow_dispatch dan push
  if ($1 == "on:" && printed_on==1) next
  if ($1 == "workflow_dispatch:" && printed_on==1) next
  if ($1 == "push:" && printed_on==1) next

  # Perbaiki on: section pertama
  if ($1 == "on:") {
    printed_on=1
    print "on:"
    print "  workflow_dispatch:"
    print "  push:"
    print "    branches: [ main ]"
    next
  }

  print
}
END {
  if (!printed_on) {
    print "on:"
    print "  workflow_dispatch:"
    print "  push:"
    print "    branches: [ main ]"
  }
}' "$WF_PATH.bak" > "$WF_PATH"

echo "✅ YAML sudah dibersihkan dari duplikat."
echo "🔍 Preview hasil:"
head -20 "$WF_PATH"

# Commit & push
echo "📦 Commit & push perubahan..."
git add "$WF_PATH"
git commit -m "fix: clean duplicated workflow_dispatch section" || echo "ℹ️ Tidak ada perubahan untuk commit"
git push || echo "ℹ️ Push mungkin sudah up-to-date"

# Tunggu agar GitHub sinkron
echo "⏳ Menunggu sinkronisasi GitHub (5 detik)..."
sleep 5

# Trigger ulang workflow
echo "⚡ Trigger ulang workflow: Android Release..."
if gh workflow run android-release.yml --ref main; then
  echo "✅ Workflow berhasil ditrigger!"
else
  echo "⚠️ Masih gagal trigger, kemungkinan cache GitHub belum refresh."
  echo "🩵 Tips: tunggu ±30 detik lalu jalankan ulang perintah ini."
fi

echo "✨ Selesai — workflow_dispatch sudah valid & bersih!"
