#!/bin/bash
echo "🚀 Auto Fix + Rerun Workflow"

# 1. Jalankan fix-build-error.sh
./fix-build-error.sh

# 2. Trigger ulang workflow
echo "⚡ Menjalankan ulang workflow android.yml..."
gh workflow run android.yml

# 3. Tunggu 10 detik biar workflow terdaftar
sleep 10

# 4. Ambil Run ID terbaru
RUN_ID=$(gh run list --workflow=android.yml --limit 1 --json databaseId -q '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak ada Run ID ditemukan"
  exit 1
fi

echo "ℹ️ Run ID terbaru: $RUN_ID"

# 5. Ambil error log terakhir
gh run view $RUN_ID --log | grep "e: " || echo "✅ Tidak ada error Kotlin/Gradle"
