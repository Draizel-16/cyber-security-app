#!/bin/bash
echo "=== Ambil hanya log error terakhir dari GitHub Actions ==="

# Ambil run ID terakhir
RUN_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada workflow ditemukan."
  exit 1
fi

echo "📦 Workflow terakhir ID: $RUN_ID"

# Ambil log error saja (default 15 baris terakhir)
if [ "$1" == "full" ]; then
  gh run view $RUN_ID --log | grep -i "error" | tee gh_last_error.log
else
  gh run view $RUN_ID --log | grep -i "error" | tail -n 15 | tee gh_last_error.log
fi

echo "✅ Error tersimpan di gh_last_error.log"
