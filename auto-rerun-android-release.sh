#!/bin/bash
set -e

echo "🚀 Auto Fix + Trigger + Pantau Workflow Android Release"

# 1. Pastikan workflow punya local.properties
if ! grep -q "local.properties" .github/workflows/android.yml; then
  echo "📦 Tambah step local.properties ke workflow..."
  sed -i '/- name: Build Release APK/i \      - name: Create local.properties\n        run: echo "sdk.dir=$ANDROID_HOME" > local.properties' .github/workflows/android.yml
  git add .github/workflows/android.yml
  git commit -m "fix: add local.properties step"
  git push origin main
else
  echo "ℹ️ Step local.properties sudah ada"
fi

# 2. Trigger workflow Android Release
echo "⚡ Trigger workflow: Android Release..."
gh workflow run "Android Release" --ref main

# 3. Ambil run ID terbaru
echo "⏳ Ambil run ID terbaru..."
RUN_ID=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId --jq '.[0].databaseId')
echo "ℹ️ Run ID: $RUN_ID"

# 4. Loop tunggu sampai selesai
while true; do
  STATUS=$(gh run view $RUN_ID --json status,conclusion --jq '.status + " " + (.conclusion // "")')
  echo "📊 Status: $STATUS"
  if [[ "$STATUS" == "completed success" ]]; then
    echo "✅ Workflow selesai sukses!"
    echo "📦 Cek artifacts APK di: https://github.com/Draizel-16/cyber-security-app/actions/runs/$RUN_ID"
    exit 0
  elif [[ "$STATUS" == completed* ]]; then
    echo "❌ Workflow gagal, ambil error Kotlin/Gradle/Java..."
    gh run view $RUN_ID --log | grep -iE "e: |error|Exception" | tail -n 20
    exit 1
  fi
  sleep 30
done
