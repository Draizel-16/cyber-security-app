#!/bin/bash
set -e

echo "🚀 Trigger ulang workflow Android Release + Pantau + Ambil Error"

WF_NAME="Android Release"
WF_FILE="android-release.yml"

# Trigger workflow
echo "⚡ Trigger workflow: $WF_NAME..."
gh workflow run "$WF_NAME" --ref main

# Ambil run ID terbaru
echo "⏳ Ambil run ID terbaru..."
LATEST=$(gh run list --workflow="$WF_FILE" --limit 1 --json databaseId -q '.[0].databaseId')

if [ -z "$LATEST" ]; then
  echo "❌ Tidak ada run ID ditemukan"
  exit 1
fi

echo "ℹ️ Run ID: $LATEST"

# Pantau sampai selesai
gh run watch $LATEST --exit-status

# Ambil error terakhir (jika ada)
echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view $LATEST --log | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle"
