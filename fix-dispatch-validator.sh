#!/bin/bash
set -e

echo "🚀 Validasi & Auto-fix workflow_dispatch di android.yml"

WF_FILE=".github/workflows/android.yml"

if [ ! -f "$WF_FILE" ]; then
  echo "❌ File $WF_FILE tidak ditemukan!"
  exit 1
fi

# 1. Cek apakah workflow_dispatch ada
if grep -q "workflow_dispatch" "$WF_FILE"; then
  echo "ℹ️ workflow_dispatch ditemukan, cek indentasi..."
  if ! grep -A2 "^on:" "$WF_FILE" | grep -q "workflow_dispatch"; then
    echo "⚠️ Indentasi salah, perbaiki..."
    awk '
      /^on:/ {
        print $0
        print "  workflow_dispatch:"
        next
      }
      !/workflow_dispatch/ { print $0 }
    ' "$WF_FILE" > "$WF_FILE.tmp" && mv "$WF_FILE.tmp" "$WF_FILE"
  else
    echo "✅ Indentasi workflow_dispatch sudah benar"
  fi
else
  echo "⚠️ workflow_dispatch tidak ada, tambahkan..."
  awk '
    /^on:/ {
      print $0
      print "  workflow_dispatch:"
      next
    }
    { print $0 }
  ' "$WF_FILE" > "$WF_FILE.tmp" && mv "$WF_FILE.tmp" "$WF_FILE"
fi

# 2. Commit jika ada perubahan
if git diff --quiet; then
  echo "ℹ️ Tidak ada perubahan untuk commit"
else
  git add "$WF_FILE"
  git commit -m "fix: ensure workflow_dispatch in android.yml"
  git push origin main
fi

# 3. Cari nama workflow
WF_NAME=$(gh workflow list --limit 1 --json name,filePath -q '.[] | select(.filePath=="'"$WF_FILE"'") | .name')
if [ -z "$WF_NAME" ]; then
  echo "❌ Tidak bisa menemukan workflow dari $WF_FILE"
  exit 1
fi
echo "ℹ️ Workflow terdeteksi: $WF_NAME"

# 4. Jalankan workflow
gh workflow run "$WF_NAME" --ref main

# 5. Ambil run ID terbaru
LATEST=$(gh run list --workflow="$WF_NAME" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# 6. Tunggu selesai
gh run watch "$LATEST" --exit-status

# 7. Ambil error Kotlin/Gradle terakhir
echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view "$LATEST" --log | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle"
