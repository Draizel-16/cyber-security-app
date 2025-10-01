#!/bin/bash
set -e

echo "🚀 Setup Android CI Workflow (Full Auto) ==="

pkg update -y && pkg upgrade -y
pkg install -y git python python-pip
pip install pyyaml --break-system-packages || true

mkdir -p .github/workflows

cat > .github/workflows/android.yml <<'YAML'
name: Android CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          distribution: temurin
          java-version: 17

      - name: Decode Keystore
        env:
          KEYSTORE_B64: ${{ secrets.KEYSTORE_B64 }}
        run: |
          echo "$KEYSTORE_B64" | base64 -d > release.keystore
          cat > keystore.properties <<EOKEY
          storeFile=release.keystore
          storePassword=${{ secrets.KEY_STORE_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          EOKEY

      - name: Restore Firebase config
        env:
          GS_B64: ${{ secrets.GOOGLE_SERVICES_JSON_BASE64 }}
        run: |
          mkdir -p app
          echo "$GS_B64" | base64 -d > app/google-services.json

      - name: Build with Gradle
        run: ./gradlew assembleRelease
YAML

python3 -c "import yaml; yaml.safe_load(open('.github/workflows/android.yml')); print('✅ YAML valid')"

git add .github/workflows/android.yml
git commit -m "ci: setup android workflow" || echo "⚠️ Tidak ada perubahan"
git push origin main

echo "=== ✅ Workflow sudah siap ==="
