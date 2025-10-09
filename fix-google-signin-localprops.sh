#!/bin/bash
set -e

echo "🚀 Auto Fix Google Sign-In + local.properties + Rerun Workflow"

WF_FILE=".github/workflows/android.yml"
BUILD_FILE="app/build.gradle"
DASHBOARD_FILE="app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt"

# --- 1. Tambahkan local.properties step ke workflow ---
if ! grep -q "Setup local.properties" "$WF_FILE"; then
  echo "📦 Tambah step local.properties ke $WF_FILE..."
  awk '
    /- name: Build/ && !added {
      print "    - name: Setup local.properties"
      print "      run: echo \"sdk.dir=$ANDROID_HOME\" > local.properties"
      added=1
    }
    {print}
  ' "$WF_FILE" > "$WF_FILE.tmp" && mv "$WF_FILE.tmp" "$WF_FILE"
else
  echo "ℹ️ Step local.properties sudah ada"
fi

# --- 2. Pastikan dependency play-services-auth ---
if ! grep -q "play-services-auth" "$BUILD_FILE"; then
  echo "📦 Tambah dependency play-services-auth ke build.gradle..."
  sed -i '/implementation/s/$/\n    implementation "com.google.android.gms:play-services-auth:20.7.0"/' "$BUILD_FILE"
else
  echo "ℹ️ Dependency play-services-auth sudah ada"
fi

# --- 3. Tambahkan import GoogleSignInOptions ---
if ! grep -q "GoogleSignInOptions" "$DASHBOARD_FILE"; then
  echo "📦 Tambah import GoogleSignInOptions ke DashboardActivity.kt..."
  sed -i '/import com.google.android.gms.auth.api.signin.GoogleSignIn/a import com.google.android.gms.auth.api.signin.GoogleSignInOptions' "$DASHBOARD_FILE"
else
  echo "ℹ️ Import GoogleSignInOptions sudah ada di DashboardActivity.kt"
fi

# --- 4. Commit & Push ---
if [ -n "$(git status --porcelain)" ]; then
  echo "📦 Commit & Push perubahan..."
  git add "$WF_FILE" "$BUILD_FILE" "$DASHBOARD_FILE"
  git commit -m "fix: add local.properties step + GoogleSignInOptions import"
  git push origin main
else
  echo "ℹ️ Tidak ada perubahan baru untuk commit"
fi

# --- 5. Trigger ulang workflow Android Release ---
echo "⚡ Trigger workflow: Android Release..."
gh workflow run "Android Release" --ref main

# --- 6. Ambil run ID terbaru ---
echo "⏳ Ambil run ID terbaru..."
LATEST=$(gh run list --workflow="Android Release" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID: $LATEST"

# --- 7. Tunggu sampai selesai ---
echo "⏳ Menunggu workflow selesai..."
gh run watch "$LATEST" --exit-status || true

# --- 8. Ambil error terakhir kalau ada ---
echo "⏳ Ambil error Kotlin/Gradle/Java terakhir..."
gh run view "$LATEST" --log | grep -E "e: |FAILURE|Error" | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle/Java"
