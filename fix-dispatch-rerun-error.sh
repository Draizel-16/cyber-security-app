#!/bin/bash
set -e

echo "🚀 Auto-fix workflow_dispatch + Rerun + Cek Error"

WF_FILE=".github/workflows/android.yml"

# --- 1. Validasi blok 'on:' ---
echo "ℹ️ Validasi blok 'on:' di $WF_FILE..."
if grep -q "^on:" "$WF_FILE"; then
    BLOCK=$(awk '/^on:/{flag=1;next}/^[^[:space:]]/{flag=0}flag' "$WF_FILE")
    if [[ -z "$BLOCK" || ! "$BLOCK" =~ workflow_dispatch ]]; then
        echo "⚠️ Blok 'on:' kosong / tanpa workflow_dispatch. Perbaiki..."
        sed -i '/^on:/a\  push:\n    branches:\n      - main\n  workflow_dispatch:' "$WF_FILE"
        git add "$WF_FILE"
        git commit -m "fix: tambahkan workflow_dispatch + push di blok 'on:'" || echo "ℹ️ Tidak ada perubahan untuk commit"
        git push origin main
    else
        echo "✅ Blok 'on:' sudah benar"
    fi
else
    echo "❌ Tidak ada blok 'on:' → tambahkan"
    echo -e "on:\n  push:\n    branches:\n      - main\n  workflow_dispatch:" | cat - "$WF_FILE" > temp.yml && mv temp.yml "$WF_FILE"
    git add "$WF_FILE"
    git commit -m "fix: tambahkan blok on: dengan push + workflow_dispatch"
    git push origin main
fi

# --- 2. Jalankan ulang workflow (pakai path, bukan nama) ---
echo "⚡ Trigger ulang workflow..."
WF_PATH="android.yml"

gh workflow run "$WF_PATH" --ref main || {
    echo "❌ Gagal trigger workflow dispatch"
    exit 1
}

# --- 3. Ambil Run ID terbaru ---
LATEST=$(gh run list --workflow="$WF_PATH" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# --- 4. Tunggu & cek hasil ---
gh run watch "$LATEST" --exit-status || true

echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view "$LATEST" --log-failed | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle"
