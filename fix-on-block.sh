#!/bin/bash
set -e

WF_FILE=".github/workflows/android.yml"

echo "🚀 Auto-fix blok 'on:' di $WF_FILE"

# Pastikan file ada
if [ ! -f "$WF_FILE" ]; then
  echo "❌ File $WF_FILE tidak ditemukan"
  exit 1
fi

# Cek apakah file punya 'on:' kosong
if grep -q "^on:\s*$" "$WF_FILE"; then
  echo "ℹ️ Blok 'on:' ditemukan tapi kosong. Tambahkan workflow_dispatch..."
  # Tambahkan push dan workflow_dispatch default
  sed -i '/^on:\s*$/a\  push:\n    branches:\n      - main\n  workflow_dispatch:' "$WF_FILE"
  git add "$WF_FILE"
  git commit -m "fix: tambah workflow_dispatch + push di blok 'on:'" || echo "ℹ️ Tidak ada perubahan untuk commit"
  git push origin main
else
  # Kalau sudah ada, pastikan workflow_dispatch masuk
  if ! grep -q "workflow_dispatch:" "$WF_FILE"; then
    echo "ℹ️ Tambahkan workflow_dispatch di blok 'on:'"
    sed -i '/^on:/a\  workflow_dispatch:' "$WF_FILE"
    git add "$WF_FILE"
    git commit -m "fix: tambahkan workflow_dispatch di blok 'on:'" || echo "ℹ️ Tidak ada perubahan untuk commit"
    git push origin main
  else
    echo "✅ workflow_dispatch sudah ada"
  fi
fi

echo "✨ Selesai, sekarang coba rerun workflow dengan:"
echo "   gh workflow run android.yml --ref main"
