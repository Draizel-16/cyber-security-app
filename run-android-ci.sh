#!/bin/bash
echo "🚀 Trigger Android CI Workflow"

# Pastikan user sudah login ke gh
if ! gh auth status &>/dev/null; then
  echo "❌ Belum login GitHub CLI. Jalankan: gh auth login"
  exit 1
fi

# Trigger workflow
gh workflow run android.yml --ref main

# Tunggu 5 detik biar workflow tercatat
sleep 5

# Ambil list run terakhir
echo "📡 Ambil status run terbaru..."
gh run list --limit 1
