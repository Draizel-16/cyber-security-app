#!/bin/bash
echo "🚀 Ambil error terakhir dari workflow android.yml"

# Ambil ID run terbaru langsung dari GitHub CLI tanpa jq
RUN_ID=$(gh run list --workflow=android.yml --limit 1 --json databaseId --jq '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada workflow ditemukan."
  exit 1
fi

echo "ℹ️ Run ID terbaru: $RUN_ID"

# Ambil log error dari run terbaru
gh run view "$RUN_ID" --log | tail -n 50
