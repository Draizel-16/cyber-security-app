#!/bin/bash
set -e

WF_FILE=".github/workflows/android.yml"

echo "🚀 Auto Fix blok 'on:' + Trigger + Cek Error"

if [ ! -f "$WF_FILE" ]; then
  echo "❌ File $WF_FILE tidak ditemukan!"
  exit 1
fi

# Backup dulu
cp "$WF_FILE" "$WF_FILE.bak"

# Overwrite blok on:
awk '
BEGIN {fixed=0}
/^on:/ {
  print "on:"
  print "  push:"
  print "    branches:"
  print "      - main"
  print "  workflow_dispatch:"
  fixed=1
  skip=1
  next
}
skip && /^[a-zA-Z0-9_]+:/ {skip=0}
!skip {print}
END {
  if (!fixed) {
    print "on:"
    print "  push:"
    print "    branches:"
    print "      - main"
    print "  workflow_dispatch:"
  }
}
' "$WF_FILE.bak" > "$WF_FILE"

echo "✅ Blok 'on:' sudah diperbaiki"
grep -A5 '^on:' "$WF_FILE"

# Commit & push
git add "$WF_FILE"
git commit -m "fix: reset workflow on: block with push + workflow_dispatch" || echo "ℹ️ Tidak ada perubahan baru"
git push origin main

# Trigger workflow
echo "⚡ Trigger ulang workflow..."
gh workflow run android.yml --ref main || {
  echo "❌ Gagal trigger workflow dispatch"
  exit 1
}

# Ambil run ID terbaru
LATEST=$(gh run list --workflow=android.yml --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# Tunggu & cek error
gh run watch "$LATEST" --exit-status || true
echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view "$LATEST" --log | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle"
