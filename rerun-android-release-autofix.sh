#!/bin/bash
set -e

echo "🚀 Trigger ulang workflow Android Release + Auto Rerun jika gagal"

trigger_workflow() {
  echo "⚡ Trigger workflow: Android Release..."
  gh workflow run "Android Release" --ref main

  echo "⏳ Ambil run ID terbaru..."
  RUN_ID=$(gh run list --workflow="Android Release" --limit 1 --json databaseId -q '.[0].databaseId')
  echo "ℹ️ Run ID: $RUN_ID"

  echo "⏳ Menunggu workflow selesai..."
  gh run watch "$RUN_ID" --exit-status || true

  echo "⏳ Ambil error Kotlin/Gradle/Java terakhir..."
  gh run view "$RUN_ID" --log | grep -E "(FAILURE|Error|Exception|e: )" | tail -n 50 || echo "✅ Tidak ada error terdeteksi"

  # return status workflow (success/failure/cancelled)
  STATUS=$(gh run view "$RUN_ID" --json conclusion -q ".conclusion")
  echo "📊 Status run: $STATUS"
}

# --- Jalankan pertama kali ---
trigger_workflow

# --- Jika gagal, coba rerun sekali lagi ---
if [[ "$STATUS" == "failure" ]]; then
  echo "⚠️ Workflow gagal, coba rerun sekali lagi..."
  trigger_workflow
fi

echo "✨ Selesai"
