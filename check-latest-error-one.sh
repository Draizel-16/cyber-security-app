#!/bin/bash
echo "🚀 Ambil error terakhir dari workflow android.yml (otomatis)"
LATEST=$(gh run list --workflow=android.yml --limit 1 --json databaseId -q '.[0].databaseId')

if [ -z "$LATEST" ]; then
  echo "❌ Tidak ada workflow ditemukan."
  exit 1
fi

echo "ℹ️ Run ID terbaru: $LATEST"
echo "⏳ Ambil log error terakhir..."
gh run view "$LATEST" --log-failed | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle ditemukan."
