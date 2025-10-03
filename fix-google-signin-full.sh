#!/bin/bash
echo "🚀 Auto Fix Google Sign-In + Rerun Workflow + Cek Error"

WORKFLOW_FILE=".github/workflows/android.yml"
BUILD_FILE="app/build.gradle"
DASHBOARD_FILE="app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt"
LOGIN_FILE="app/src/main/java/com/example/cybersecurityapp/ui/LoginActivity.kt"

# 1. Patch workflow untuk local.properties
if grep -q "sdk.dir" "$WORKFLOW_FILE"; then
  echo "ℹ️ Step local.properties sudah ada di $WORKFLOW_FILE"
else
  echo "📦 Tambah step local.properties ke $WORKFLOW_FILE..."
  sed -i '/- name: Build with Gradle/i \
    - name: Setup Android SDK\n      run: echo "sdk.dir=\$ANDROID_SDK_ROOT" > local.properties\n' "$WORKFLOW_FILE"
fi

# 2. Pastikan dependency play-services-auth
if grep -q "play-services-auth" "$BUILD_FILE"; then
  echo "ℹ️ Dependency play-services-auth sudah ada"
else
  echo "📦 Tambah dependency play-services-auth ke $BUILD_FILE..."
  sed -i '/implementation/ a \    implementation "com.google.android.gms:play-services-auth:20.7.0"' "$BUILD_FILE"
fi

# 3. Tambahkan imports ke DashboardActivity.kt
if grep -q "GoogleSignInOptions" "$DASHBOARD_FILE"; then
  echo "ℹ️ DashboardActivity.kt sudah punya imports"
else
  echo "➕ Tambah imports ke DashboardActivity.kt..."
  sed -i '1i\
import com.google.android.gms.auth.api.signin.GoogleSignIn\
import com.google.android.gms.auth.api.signin.GoogleSignInClient\
import com.google.android.gms.auth.api.signin.GoogleSignInOptions\
import com.google.android.gms.common.api.ApiException\
' "$DASHBOARD_FILE"
fi

# 4. Tambahkan imports ke LoginActivity.kt
if grep -q "GoogleSignInOptions" "$LOGIN_FILE"; then
  echo "ℹ️ LoginActivity.kt sudah punya imports"
else
  echo "➕ Tambah imports ke LoginActivity.kt..."
  sed -i '1i\
import com.google.android.gms.auth.api.signin.GoogleSignIn\
import com.google.android.gms.auth.api.signin.GoogleSignInClient\
import com.google.android.gms.auth.api.signin.GoogleSignInOptions\
import com.google.android.gms.common.api.ApiException\
' "$LOGIN_FILE"
fi

# 5. Commit & Push
echo "📦 Commit & Push perubahan..."
git add "$WORKFLOW_FILE" "$BUILD_FILE" "$DASHBOARD_FILE" "$LOGIN_FILE"
git commit -m "fix: Google Sign-In imports + local.properties"
git push origin main

# 6. Rerun workflow
echo "⚡ Menjalankan ulang workflow android.yml..."
LATEST=$(gh run list --workflow=android.yml --limit 1 --json databaseId -q '.[0].databaseId')
gh workflow run android.yml
LATEST=$(gh run list --workflow=android.yml --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# 7. Tunggu workflow selesai
gh run watch $LATEST --exit-status

# 8. Ambil error terakhir jika ada
echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view $LATEST --log | grep "e: " | tail -n 20
