#!/bin/bash
set -e

echo "🚀 Validasi workflow_dispatch + Auto Rerun Workflow"

WF_FILE=".github/workflows/android.yml"

# 1. Validasi workflow_dispatch
if [[ ! -f "$WF_FILE" ]]; then
  echo "❌ Workflow file $WF_FILE tidak ditemukan!"
  exit 1
fi

if grep -q "workflow_dispatch:" "$WF_FILE"; then
  echo "ℹ️ workflow_dispatch ditemukan, cek posisi..."
  if grep -A3 "^on:" "$WF_FILE" | grep -q "workflow_dispatch:"; then
    echo "✅ workflow_dispatch sudah di bawah on:"
  else
    echo "⚠️ workflow_dispatch salah posisi, auto-fix..."
    sed -i '/^on:/a \  workflow_dispatch:' "$WF_FILE"
    git add "$WF_FILE"
    git commit -m "fix: perbaiki posisi workflow_dispatch"
    git push origin main
  fi
else
  echo "⚠️ workflow_dispatch tidak ditemukan, auto-tambah..."
  sed -i '/^on:/a \  workflow_dispatch:' "$WF_FILE"
  git add "$WF_FILE"
  git commit -m "fix: tambahkan workflow_dispatch ke android.yml"
  git push origin main
fi

# 2. Cari nama workflow
WF_NAME=$(grep -m1 "^name:" "$WF_FILE" | sed 's/name: //g' | xargs)
echo "ℹ️ Workflow terdeteksi: $WF_NAME"

# 3. Jalankan workflow (pakai nama, bukan path)
gh workflow run "$WF_NAME" --ref main || {
  echo "❌ Gagal trigger workflow dispatch"
  exit 1
}

# 4. Ambil Run ID terbaru
LATEST=$(gh run list --workflow="$WF_NAME" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# 5. Tunggu workflow selesai
gh run watch "$LATEST" --exit-status || true

# 6. Ambil error Kotlin/Gradle terakhir
echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view "$LATEST" --log | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle"
