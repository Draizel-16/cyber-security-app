#!/bin/bash
set -e

WF_FILE=".github/workflows/android.yml"

echo "🚀 Enable workflow_dispatch di $WF_FILE + jalankan ulang workflow"

# 1. Tambahkan workflow_dispatch kalau belum ada
if ! grep -q "workflow_dispatch:" "$WF_FILE"; then
  echo "📦 Menambahkan workflow_dispatch..."
  # tambahkan tepat setelah baris on:
  sed -i '/^on:/a\  workflow_dispatch:' "$WF_FILE"
else
  echo "ℹ️ workflow_dispatch sudah ada"
fi

# 2. Commit & push perubahan
git add "$WF_FILE"
git commit -m "chore: enable workflow_dispatch for Android CI" || echo "ℹ️ Tidak ada perubahan untuk di-commit"
git push origin main

# 3. Dapatkan nama workflow
WF_NAME=$(grep -m1 "^name:" "$WF_FILE" | sed 's/name: //g' | xargs)
echo "ℹ️ Workflow terdeteksi: $WF_NAME"

# 4. Jalankan ulang workflow
gh workflow run "$WF_NAME" --ref main

# 5. Ambil run ID terbaru
LATEST=$(gh run list --workflow="$WF_NAME" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# 6. Tunggu workflow selesai
gh run watch "$LATEST" --exit-status || true

# 7. Ambil error Kotlin/Gradle terakhir
echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view "$LATEST" --log | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle"
