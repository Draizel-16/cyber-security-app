#!/bin/bash
set -e

WF_FILE=".github/workflows/android.yml"

echo "🚀 Auto Fix Google Sign-In + Workflow Dispatch + Rerun"

# 1. Pastikan workflow_dispatch ada
if ! grep -q "workflow_dispatch:" "$WF_FILE"; then
  echo "📦 Menambahkan workflow_dispatch ke $WF_FILE..."
  sed -i '/^on:/a\  workflow_dispatch:' "$WF_FILE"
else
  echo "ℹ️ workflow_dispatch sudah ada"
fi

# 2. Pastikan step local.properties ada
if ! grep -q "local.properties" "$WF_FILE"; then
  echo "📦 Tambah step local.properties ke workflow..."
  sed -i '/- name: Build with Gradle/i\      - name: Setup local.properties\n        run: echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties' "$WF_FILE"
else
  echo "ℹ️ Step local.properties sudah ada"
fi

# 3. Tambah dependency play-services-auth
if ! grep -q "play-services-auth" app/build.gradle; then
  echo "📦 Tambah dependency play-services-auth ke build.gradle..."
  sed -i '/implementation/s/$/\n    implementation "com.google.android.gms:play-services-auth:20.7.0"/' app/build.gradle
else
  echo "ℹ️ Dependency play-services-auth sudah ada"
fi

# 4. Tambah import Google Sign-In di DashboardActivity.kt
DASHBOARD="app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt"
if ! grep -q "GoogleSignIn" "$DASHBOARD"; then
  echo "📦 Tambah import GoogleSignIn ke DashboardActivity.kt..."
  sed -i '1i\
import com.google.android.gms.auth.api.signin.GoogleSignIn\
import com.google.android.gms.auth.api.signin.GoogleSignInOptions\
' "$DASHBOARD"
else
  echo "ℹ️ DashboardActivity.kt sudah punya imports"
fi

# 5. Tambah import Google Sign-In di LoginActivity.kt
LOGIN="app/src/main/java/com/example/cybersecurityapp/ui/LoginActivity.kt"
if ! grep -q "GoogleSignIn" "$LOGIN"; then
  echo "📦 Tambah import Google Sign-In ke LoginActivity.kt..."
  sed -i '1i\
import com.google.android.gms.auth.api.signin.GoogleSignIn\
import com.google.android.gms.auth.api.signin.GoogleSignInOptions\
import com.google.android.gms.auth.api.signin.GoogleSignInClient\
import com.google.android.gms.common.api.ApiException\
' "$LOGIN"
else
  echo "ℹ️ LoginActivity.kt sudah punya imports"
fi

# 6. Tambah txtWelcome & btnLogout ke activity_dashboard.xml
XML="app/src/main/res/layout/activity_dashboard.xml"
if ! grep -q "txtWelcome" "$XML"; then
  echo "📦 Tambah txtWelcome & btnLogout ke activity_dashboard.xml..."
  sed -i '/<\/LinearLayout>/i\
    <TextView\
        android:id="@+id/txtWelcome"\
        android:layout_width="wrap_content"\
        android:layout_height="wrap_content"\
        android:text="Welcome!"\
        android:textSize="18sp"\
        android:layout_marginTop="16dp"/>\
\
    <Button\
        android:id="@+id/btnLogout"\
        android:layout_width="wrap_content"\
        android:layout_height="wrap_content"\
        android:text="Logout"\
        android:layout_marginTop="16dp"/>\
' "$XML"
else
  echo "ℹ️ activity_dashboard.xml sudah ada views"
fi

# 7. Commit & push
echo "📦 Commit & Push perubahan..."
git add .
git commit -m "fix: enable workflow_dispatch + Google Sign-In imports + local.properties" || echo "ℹ️ Tidak ada perubahan untuk di-commit"
git push origin main

# 8. Dapatkan nama workflow
WF_NAME=$(grep -m1 "^name:" "$WF_FILE" | sed 's/name: //g' | xargs)
echo "ℹ️ Workflow terdeteksi: $WF_NAME"

# 9. Jalankan ulang workflow
gh workflow run "$WF_NAME" --ref main

# 10. Ambil run ID terbaru
LATEST=$(gh run list --workflow="$WF_NAME" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# 11. Tunggu workflow selesai
gh run watch "$LATEST" --exit-status || true

# 12. Ambil error terakhir
echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view "$LATEST" --log | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle"
