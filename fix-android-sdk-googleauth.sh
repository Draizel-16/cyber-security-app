#!/bin/bash
set -e

echo "🚀 Auto Fix Android SDK + GoogleSignIn + Rerun Workflow"

WF=".github/workflows/android.yml"
GRADLE="app/build.gradle"
DASH="app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt"

# --- Tambahkan step install Android SDK ke workflow ---
if ! grep -q "sdkmanager" "$WF"; then
  echo "📦 Tambah step install Android SDK ke $WF..."
  sed -i '/- name: Build Release APK/i\
      - name: Install Android SDK Tools\n        run: |\n          sudo apt-get update\n          sudo apt-get install -y wget unzip\n          wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmd-tools.zip\n          mkdir -p $HOME/android-sdk/cmdline-tools\n          unzip cmd-tools.zip -d $HOME/android-sdk/cmdline-tools\n          yes | $HOME/android-sdk/cmdline-tools/cmdline-tools/bin/sdkmanager --licenses\n          echo "sdk.dir=$HOME/android-sdk" > local.properties' "$WF"
fi

# --- Pastikan dependency play-services-auth ---
if ! grep -q "play-services-auth" "$GRADLE"; then
  echo "📦 Tambah dependency play-services-auth ke $GRADLE..."
  sed -i '/implementation "androidx.appcompat:appcompat/a\    implementation "com.google.android.gms:play-services-auth:20.7.0"' "$GRADLE"
else
  echo "ℹ️ Dependency play-services-auth sudah ada di $GRADLE"
fi

# --- Pastikan import GoogleSignInOptions di DashboardActivity.kt ---
if ! grep -q "GoogleSignInOptions" "$DASH"; then
  echo "📦 Tambah import GoogleSignInOptions ke $DASH..."
  sed -i '/import androidx.appcompat.app.AppCompatActivity/a\
import com.google.android.gms.auth.api.signin.GoogleSignInOptions' "$DASH"
else
  echo "ℹ️ Import GoogleSignInOptions sudah ada di $DASH"
fi

# --- Commit hanya file penting ---
echo "📦 Commit & Push perubahan..."
git add "$WF" "$GRADLE" "$DASH"
git commit -m "fix: add Android SDK install + GoogleSignInOptions support" || echo "ℹ️ Tidak ada perubahan baru untuk commit"
git push origin main

# --- Trigger workflow Android Release ---
echo "⚡ Trigger workflow: Android Release..."
gh workflow run "Android Release" --ref main

echo "⏳ Ambil run ID terbaru..."
LATEST=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID: $LATEST"

echo "⏳ Menunggu workflow selesai..."
gh run watch "$LATEST" --exit-status || true

echo "⏳ Ambil error Kotlin/Gradle/Java terakhir..."
gh run view "$LATEST" --log | grep -E "e: |FAILURE|error" | tail -n 30 || echo "✅ Tidak ada error Kotlin/Gradle/Java"
