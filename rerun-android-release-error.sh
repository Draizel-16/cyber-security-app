#!/bin/bash
set -e

echo "🚀 Trigger ulang workflow Android Release + Pantau + Ambil Error"

# 1. Trigger workflow
echo "⚡ Trigger workflow: Android Release..."
gh workflow run "Android Release" --ref main

# 2. Ambil run ID terbaru
echo "⏳ Ambil run ID terbaru..."
sleep 5
RUN_ID=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId -q '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
  echo "❌ Tidak bisa menemukan Run ID"
  exit 1
fi

echo "ℹ️ Run ID: $RUN_ID"

# 3. Pantau sampai selesai
gh run watch "$RUN_ID" --exit-status || true

# 4. Ambil error terakhir
echo "⏳ Ambil error Kotlin/Gradle/Java terakhir..."
gh run view "$RUN_ID" --log | grep -E "(FAILURE|Error|Exception|e: )" | tail -n 50 || echo "✅ Tidak ada error terdeteksi"
