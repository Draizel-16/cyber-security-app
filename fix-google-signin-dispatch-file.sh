#!/bin/bash
set -e

echo "🚀 Auto Fix Google Sign-In + Workflow Dispatch (pakai file) + Rerun"

WF_FILE="android.yml"

# 1. Pastikan workflow_dispatch ada
if ! grep -q "workflow_dispatch:" .github/workflows/$WF_FILE; then
  echo "➕ Tambah workflow_dispatch ke $WF_FILE..."
  sed -i '/on:/a\  workflow_dispatch:' .github/workflows/$WF_FILE
  git add .github/workflows/$WF_FILE
fi

# 2. Pastikan step local.properties ada
if ! grep -q "echo \"sdk.dir" .github/workflows/$WF_FILE; then
  echo "➕ Tambah step local.properties ke $WF_FILE..."
  sed -i '/- uses: actions\/checkout/a\      - name: Create local.properties\n        run: echo "sdk.dir=$ANDROID_HOME" > local.properties' .github/workflows/$WF_FILE
  git add .github/workflows/$WF_FILE
fi

# 3. Pastikan dependency ada di build.gradle
if ! grep -q "play-services-auth" app/build.gradle; then
  echo "📦 Tambah dependency Google Sign-In ke build.gradle..."
  sed -i '/implementation/ a\    implementation "com.google.android.gms:play-services-auth:20.7.0"' app/build.gradle
  git add app/build.gradle
else
  echo "ℹ️ Dependency play-services-auth sudah ada"
fi

# 4. Pastikan imports ada di DashboardActivity
if ! grep -q "import com.google.android.gms.auth.api.signin.GoogleSignIn" app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt; then
  echo "➕ Tambah imports ke DashboardActivity.kt..."
  sed -i '1i\
import com.google.android.gms.auth.api.signin.GoogleSignIn\nimport com.google.android.gms.auth.api.signin.GoogleSignInOptions\nimport com.google.android.gms.common.api.ApiException' app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt
  git add app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt
else
  echo "ℹ️ DashboardActivity.kt sudah punya imports"
fi

# 5. Pastikan imports ada di LoginActivity
if ! grep -q "import com.google.android.gms.auth.api.signin.GoogleSignIn" app/src/main/java/com/example/cybersecurityapp/ui/LoginActivity.kt; then
  echo "➕ Tambah imports ke LoginActivity.kt..."
  sed -i '1i\
import com.google.android.gms.auth.api.signin.GoogleSignIn\nimport com.google.android.gms.auth.api.signin.GoogleSignInClient\nimport com.google.android.gms.auth.api.signin.GoogleSignInOptions\nimport com.google.android.gms.common.api.ApiException' app/src/main/java/com/example/cybersecurityapp/ui/LoginActivity.kt
  git add app/src/main/java/com/example/cybersecurityapp/ui/LoginActivity.kt
else
  echo "ℹ️ LoginActivity.kt sudah punya imports"
fi

# 6. Tambah views di activity_dashboard.xml
if ! grep -q "txtWelcome" app/src/main/res/layout/activity_dashboard.xml; then
  echo "➕ Tambah txtWelcome & btnLogout ke activity_dashboard.xml..."
  sed -i '/<\/LinearLayout>/ i\
    <TextView\n        android:id="@+id/txtWelcome"\n        android:layout_width="wrap_content"\n        android:layout_height="wrap_content"\n        android:text="Welcome!" />\n\n    <Button\n        android:id="@+id/btnLogout"\n        android:layout_width="wrap_content"\n        android:layout_height="wrap_content"\n        android:text="Logout" />' app/src/main/res/layout/activity_dashboard.xml
  git add app/src/main/res/layout/activity_dashboard.xml
else
  echo "ℹ️ activity_dashboard.xml sudah ada views"
fi

# 7. Commit & Push
if git diff --cached --quiet; then
  echo "ℹ️ Tidak ada perubahan baru untuk commit"
else
  echo "📦 Commit & Push perubahan..."
  git commit -m "fix: enable workflow_dispatch + Google Sign-In imports + local.properties"
  git push origin main
fi

# 8. Jalankan workflow pakai file
echo "ℹ️ Workflow file: $WF_FILE"
gh workflow run "$WF_FILE" --ref main

# 9. Ambil run ID terbaru
LATEST=$(gh run list --workflow="$WF_FILE" --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# 10. Tunggu workflow selesai
gh run watch "$LATEST" --exit-status || true

# 11. Ambil error terakhir
echo "⏳ Ambil error Kotlin/Gradle terakhir..."
gh run view "$LATEST" --log | grep "e: " | tail -n 20 || echo "✅ Tidak ada error Kotlin/Gradle"
