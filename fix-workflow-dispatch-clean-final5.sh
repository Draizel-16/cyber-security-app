#!/bin/bash
set -e
echo "🚀 Ultimate Clean Fix for workflow_dispatch (v3.3 — Indentation repair)"

WF_PATH=".github/workflows/android-release.yml"
if [ ! -f "$WF_PATH" ]; then
  echo "❌ File tidak ditemukan: $WF_PATH"
  exit 1
fi

cp "$WF_PATH" "$WF_PATH.bak"
echo "📦 Backup dibuat: $WF_PATH.bak"

cat > "$WF_PATH" <<'YAML'
name: Android Release

on:
  workflow_dispatch:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Create local.properties
        run: echo "sdk.dir=$ANDROID_HOME" > local.properties

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Build with Gradle
        run: ./gradlew assembleRelease
YAML

echo "✅ YAML sudah diperbaiki dengan indentasi valid."
head -15 "$WF_PATH"

git add "$WF_PATH"
git commit -m "fix: proper indentation + valid workflow_dispatch (v3.3)" || echo "ℹ️ Tidak ada perubahan baru"
git push

echo "⏳ Tunggu sinkronisasi GitHub 10 detik..."
sleep 10

echo "⚡ Mencoba trigger workflow Android Release..."
if gh workflow run android-release.yml --ref main; then
  echo "✅ Workflow berhasil dijalankan!"
else
  echo "⚠️ Jika masih 422, cek tab Actions — tombol 'Run workflow' pasti sudah muncul sekarang."
fi
