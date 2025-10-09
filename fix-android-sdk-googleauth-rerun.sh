#!/bin/bash
set -e

WF=".github/workflows/android.yml"
GRADLE="app/build.gradle"
DASH="app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt"

echo "🚀 Auto Fix Android SDK + GoogleSignIn + Rerun Workflow (final version)"

# --- Pastikan ada step install Android SDK ---
if ! grep -q "Install Android SDK" "$WF"; then
  echo "📦 Tambah step install Android SDK ke $WF..."
  sed -i '/- name: Setup Gradle/a\
      - name: Install Android SDK\n        run: sudo apt-get update && sudo apt-get install -y android-sdk' "$WF"
else
  echo "ℹ️ Step Install Android SDK sudah ada"
fi

# --- Pastikan dependency play-services-auth ---
if ! grep -q "com.google.android.gms:play-services-auth" "$GRADLE"; then
  echo "📦 Tambah dependency play-services-auth ke $GRADLE..."
  sed -i '/implementation/ i\    implementation "com.google.android.gms:play-services-auth:21.2.0"' "$GRADLE"
else
  echo "ℹ️ Dependency play-services-auth sudah ada di $GRADLE"
fi

# --- Pastikan import GoogleSignInOptions ---
if ! grep -q "GoogleSignInOptions" "$DASH"; then
  echo "📦 Tambah import GoogleSignInOptions ke $DASH..."
  sed -i '/import android.os.Bundle/a\
import com.google.android.gms.auth.api.signin.GoogleSignInOptions' "$DASH"
else
  echo "ℹ️ Import GoogleSignInOptions sudah ada di $DASH"
fi

# --- Commit & Push ---
echo "📦 Commit & Push perubahan..."
git add "$WF" "$GRADLE" "$DASH"
if git commit -m "fix: add Android SDK install + GoogleSignInOptions support"; then
  git push origin main
else
  echo "ℹ️ Tidak ada perubahan baru untuk commit, skip push"
fi

# --- Trigger workflow ---
echo "⚡ Trigger workflow: Android Release..."
gh workflow run android-release.yml -r main

# --- Ambil run ID terbaru ---
RUN_ID=$(gh run list --workflow="android-release.yml" --json databaseId --jq '.[0].databaseId')
echo "ℹ️ Run ID: $RUN_ID"

# --- Pantau workflow ---
status="in_progress"
while [ "$status" == "in_progress" ]; do
  sleep 20
  status=$(gh run view "$RUN_ID" --json status --jq '.status')
  echo "📊 Status: $status"
done

# --- Jika gagal, retry sekali ---
if [ "$status" == "completed" ]; then
  conclusion=$(gh run view "$RUN_ID" --json conclusion --jq '.conclusion')
  if [ "$conclusion" != "success" ]; then
    echo "❌ Workflow gagal, retry sekali..."
    gh workflow run android-release.yml -r main
  else
    echo "✅ Workflow sukses!"
  fi
fi
