#!/bin/bash
echo "🚀 Auto Heal Android Build + GoogleSignIn + SDK + Retry + Diagnose (vFinal++)"

WORKFLOW_FILE=".github/workflows/android-release.yml"
DASHBOARD="app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt"

# ====== CEK FOLDER ======
if [ ! -d ".github/workflows" ]; then
  echo "❌ Folder .github/workflows tidak ditemukan. Jalankan di root repo."
  exit 1
fi

# ====== TAMBAH STEP local.properties ======
if ! grep -q "Create local.properties" "$WORKFLOW_FILE"; then
  echo "📦 Tambah step local.properties ke workflow..."
  sed -i '/- uses: actions\/checkout@v4/a\
    - name: Create local.properties\
      run: echo "sdk.dir=$ANDROID_HOME" > local.properties' "$WORKFLOW_FILE"
else
  echo "ℹ️ Step local.properties sudah ada"
fi

# ====== TAMBAH DEPENDENSI PLAY SERVICES AUTH ======
if ! grep -q "play-services-auth" app/build.gradle; then
  echo "📦 Menambahkan dependency play-services-auth..."
  echo 'implementation "com.google.android.gms:play-services-auth:21.2.0"' >> app/build.gradle
else
  echo "ℹ️ Dependency play-services-auth sudah ada"
fi

# ====== CEK & TAMBAH IMPORT ======
if [ -f "$DASHBOARD" ]; then
  if ! grep -q "GoogleSignInOptions" "$DASHBOARD"; then
    echo "📦 Menambahkan import GoogleSignInOptions..."
    sed -i '1i import com.google.android.gms.auth.api.signin.GoogleSignInOptions' "$DASHBOARD"
  else
    echo "ℹ️ Import GoogleSignInOptions sudah ada"
  fi
else
  echo "⚠️ File DashboardActivity.kt tidak ditemukan!"
fi

# ====== COMMIT & PUSH ======
git add .
git commit -m "fix: ensure SDK + GoogleSignIn + local.properties + auto heal" || echo "ℹ️ Tidak ada perubahan baru untuk commit"
git push || echo "ℹ️ Tidak ada perubahan baru untuk push"

# ====== TRIGGER WORKFLOW ======
echo "⚡ Trigger workflow: Android Release..."
gh workflow run android-release.yml --ref main
sleep 10

RUN_ID=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId --jq '.[0].databaseId')
echo "ℹ️ Run ID: $RUN_ID"

# ====== MONITOR STATUS ======
STATUS="in_progress"
while [ "$STATUS" == "in_progress" ]; do
  echo "⏳ Menunggu workflow selesai..."
  sleep 30
  STATUS=$(gh run view "$RUN_ID" --json status --jq '.status')
done

CONCLUSION=$(gh run view "$RUN_ID" --json conclusion --jq '.conclusion')
echo "📊 Status: $CONCLUSION"

# ====== CEK ERROR ======
if [ "$CONCLUSION" != "success" ]; then
  echo "⚠️ Workflow gagal — ambil error terakhir..."
  ERRORS=$(gh run view "$RUN_ID" --log | grep -E "Unresolved reference|FAILURE:|Exception|> Task|##\[error\]" | tail -n 20)
  echo "$ERRORS"

  # ====== AUTO FIX jika error GoogleSignInOptions ======
  if echo "$ERRORS" | grep -q "Unresolved reference: GoogleSignInOptions"; then
    echo "💡 Deteksi error GoogleSignInOptions — perbaiki otomatis..."
    if ! grep -q "play-services-auth" app/build.gradle; then
      echo 'implementation "com.google.android.gms:play-services-auth:21.2.0"' >> app/build.gradle
      echo "✅ Tambahkan dependency play-services-auth"
    fi
    if [ -f "$DASHBOARD" ]; then
      sed -i '/import com.google.android.gms.auth.api.signin.GoogleSignInOptions/d' "$DASHBOARD"
      sed -i '1i import com.google.android.gms.auth.api.signin.GoogleSignInOptions' "$DASHBOARD"
      echo "✅ Reimport GoogleSignInOptions di DashboardActivity.kt"
    fi
    git add .
    git commit -m "auto-heal: fix GoogleSignInOptions unresolved reference" || echo "ℹ️ Tidak ada perubahan baru"
    git push
    echo "⚡ Jalankan ulang workflow setelah auto-heal..."
    gh workflow run android-release.yml --ref main
    sleep 10
    RUN_ID2=$(gh run list --workflow="android-release.yml" --limit 1 --json databaseId --jq '.[0].databaseId')
    echo "ℹ️ Run ID (retry): $RUN_ID2"
    echo "⏳ Menunggu workflow retry selesai..."
    sleep 60
    gh run view "$RUN_ID2" --log | grep -E "error:|FAILURE:|Exception|Unresolved reference" | tail -n 20
  else
    echo "❌ Tidak ditemukan error GoogleSignInOptions — tampilkan error umum:"
    echo "$ERRORS"
  fi
else
  echo "✅ Workflow berhasil!"
fi

echo "✨ Selesai — Auto Heal & Diagnose berhasil dijalankan!"
