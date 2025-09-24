#!/bin/bash
set -e

echo "=== Ambil log error build terakhir ==="

# Ambil ID run terakhir
RUN_ID=$(gh run list --limit 1 --json databaseId -q '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada workflow run ditemukan"
  exit 1
fi

echo "📦 Workflow terakhir ID: $RUN_ID"

# Simpan log ke file sementara
gh run view $RUN_ID --log-failed > last_error.log

# Tampilkan log error
echo "=== ERROR TERDETEKSI ==="
cat last_error.log | grep -i "FAILURE\|FAILED\|error" || echo "⚠️ Tidak ada error ditemukan"

echo "======================================"
echo "📄 Log lengkap tersimpan di: last_error.log"
