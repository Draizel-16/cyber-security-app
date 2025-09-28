#!/bin/bash
set -e

echo "🚀 Setup GitHub Actions Android CI..."

# masuk ke project
cd ~/cyber-security-app

# pastikan folder workflows ada
mkdir -p .github/workflows

# tulis ulang workflow (dengan workflow_dispatch biar bisa run manual)
cat > .github/workflows/android-ci.yml <<'EOF'
name: Android CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout source
        uses: actions/checkout@v3

      - name: Setup JDK
        uses: actions/setup-java@v3
        with:
          distribution: "temurin"
          java-version: "17"

      - name: Setup Android SDK
        uses: android-actions/setup-android@v2

      - name: Decode keystore
        run: |
          echo "$SIGNING_KEY" | base64 -d > release.keystore

      - name: Build Release APK
        run: ./gradlew assembleRelease
        env:
          KEY_STORE_PASSWORD: ${{ secrets.KEY_STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          ALIAS: ${{ secrets.ALIAS }}

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: app/build/outputs/apk/release/*.apk
EOF

# paksa add file workflow (meski di-ignore)
git add -f .github/workflows/android-ci.yml

# commit
git commit -m "ci: setup Android CI workflow" || echo "ℹ️ Tidak ada perubahan baru, skip commit"

# push
git push origin main

echo "✅ Workflow berhasil dipush. Cek tab Actions di GitHub."
