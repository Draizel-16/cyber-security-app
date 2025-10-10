#!/bin/bash
echo "🚀 Auto Heal Android Release Build (vFinal++)"

WORKFLOW_FILE=".github/workflows/android-release.yml"
LOCAL_PROPS="local.properties"

# 1️⃣ Pastikan file workflow ada
if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "⚠️ File workflow tidak ditemukan, buat baru..."
  mkdir -p .github/workflows
  cat > "$WORKFLOW_FILE" <<'EOF'
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
        run: echo "sdk.dir=\$ANDROID_HOME" > local.properties

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Build Release APK
        run: ./gradlew assembleRelease
EOF
fi

# 2️⃣ Pastikan local.properties ada
if [ ! -f "$LOCAL_PROPS" ]; then
  echo "sdk.dir=$ANDROID_HOME" > local.properties
  echo "✅ local.properties dibuat."
fi

# 3️⃣ Pastikan dependency GoogleAuth ada
if ! grep -q "play-services-auth" app/build.gradle 2>/dev/null; then
  echo "📦 Menambahkan dependency GoogleAuth..."
  sed -i '/implementation/s/$/\n    implementation "com.google.android.gms:play-services-auth:21.1.0"/' app/build.gradle
fi

# 4️⃣ Perbaiki import GoogleSignInOptions jika hilang
if ! grep -q "GoogleSignInOptions" app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt 2>/dev/null; then
  sed -i '1i import com.google.android.gms.auth.api.signin.GoogleSignInOptions' app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt
  echo "✅ Import GoogleSignInOptions ditambahkan."
fi

# 5️⃣ Commit perubahan
git add .
git commit -m "auto-heal: fix SDK, GoogleSignIn, and workflow_dispatch" || echo "ℹ️ Tidak ada perubahan untuk commit."
git push origin main || echo "⚠️ Push gagal, mungkin sudah up-to-date."

# 6️⃣ Trigger ulang workflow
echo "⚡ Menjalankan ulang workflow Android Release..."
gh workflow run android-release.yml --ref main

# 7️⃣ Ambil run ID terbaru
sleep 5
RUN_ID=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null)

if [ -z "$RUN_ID" ]; then
  echo "⚠️ Tidak dapat menemukan Run ID — mungkin workflow belum muncul."
else
  echo "ℹ️ Run ID: $RUN_ID"
  echo "⏳ Menunggu workflow selesai..."
  gh run watch "$RUN_ID"
fi

echo "✨ Auto-heal selesai dijalankan!"
