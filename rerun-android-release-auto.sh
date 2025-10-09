#!/bin/bash
set -e

echo "🚀 Trigger ulang workflow Android Release + Tunggu + Ambil Error"

# Trigger workflow
echo "⚡ Trigger workflow: Android Release..."
gh workflow run "Android Release" --ref main

echo "⏳ Ambil run ID terbaru..."
RUN_ID=$(gh run list --workflow="Android Release" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID: $RUN_ID"

# Tunggu sampai status bukan in_progress/queued
STATUS="in_progress"
while [[ "$STATUS" == "in_progress" || "$STATUS" == "queued" ]]; do
  echo "⏳ Workflow masih jalan... tunggu 15 detik"
  sleep 15
  STATUS=$(gh run view "$RUN_ID" --json status -q ".status")
done

# Ambil hasil final
FINAL=$(gh run view "$RUN_ID" --json conclusion -q ".conclusion")
echo "📊 Status run: $FINAL"

# Jika gagal → ambil error terakhir
if [[ "$FINAL" == "failure" ]]; then
  echo "⚠️ Workflow gagal, ambil error Kotlin/Gradle/Java terakhir..."
  gh run view "$RUN_ID" --log | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle/Java"
else
  echo "✅ Workflow berhasil tanpa error"
fi
