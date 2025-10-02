#!/bin/bash
echo "🚀 Auto Fix Google Sign-In + Rerun Workflow + Check Errors"

# 1. Tambah dependency play-services-auth ke build.gradle
if ! grep -q "play-services-auth" app/build.gradle; then
  sed -i '/implementation/ i\    implementation "com.google.android.gms:play-services-auth:20.7.0"' app/build.gradle
  echo "✅ Dependency play-services-auth ditambahkan ke build.gradle"
else
  echo "ℹ️ Dependency play-services-auth sudah ada"
fi

# 2. Tambah import ke DashboardActivity.kt
DASHBOARD="app/src/main/java/com/example/cybersecurityapp/DashboardActivity.kt"
if [ -f "$DASHBOARD" ]; then
  if ! grep -q "GoogleSignIn" $DASHBOARD; then
    sed -i '1i\
import com.google.android.gms.auth.api.signin.GoogleSignIn\
import com.google.android.gms.auth.api.signin.GoogleSignInClient\
import com.google.android.gms.auth.api.signin.GoogleSignInOptions\
import com.google.android.gms.common.api.ApiException\
' $DASHBOARD
    echo "✅ Import GoogleSignIn ditambahkan ke DashboardActivity.kt"
  else
    echo "ℹ️ Import GoogleSignIn sudah ada di DashboardActivity.kt"
  fi
fi

# 3. Tambah import ke LoginActivity.kt
LOGIN="app/src/main/java/com/example/cybersecurityapp/ui/LoginActivity.kt"
if [ -f "$LOGIN" ]; then
  if ! grep -q "GoogleSignIn" $LOGIN; then
    sed -i '1i\
import com.google.android.gms.auth.api.signin.GoogleSignIn\
import com.google.android.gms.auth.api.signin.GoogleSignInClient\
import com.google.android.gms.auth.api.signin.GoogleSignInOptions\
import com.google.android.gms.common.api.ApiException\
' $LOGIN
    echo "✅ Import GoogleSignIn ditambahkan ke LoginActivity.kt"
  else
    echo "ℹ️ Import GoogleSignIn sudah ada di LoginActivity.kt"
  fi
fi

# 4. Patch activity_dashboard.xml
LAYOUT="app/src/main/res/layout/activity_dashboard.xml"
if [ -f "$LAYOUT" ]; then
  if ! grep -q "txtWelcome" $LAYOUT; then
    sed -i '/<\/LinearLayout>/i\
    <TextView\
        android:id="@+id/txtWelcome"\
        android:layout_width="wrap_content"\
        android:layout_height="wrap_content"\
        android:text="Welcome!"\
        android:layout_marginTop="16dp"\
        android:textSize="18sp"\
        android:textStyle="bold"\
        android:layout_gravity="center" />\
\
    <Button\
        android:id="@+id/btnLogout"\
        android:layout_width="wrap_content"\
        android:layout_height="wrap_content"\
        android:text="Logout"\
        android:layout_marginTop="24dp"\
        android:layout_gravity="center" />' $LAYOUT
    echo "✅ txtWelcome & btnLogout ditambahkan ke activity_dashboard.xml"
  else
    echo "ℹ️ Layout sudah punya txtWelcome & btnLogout"
  fi
fi

# 5. Commit & Push
git add .
git commit -m "fix: add Google Sign-In imports, dependency & dashboard views" || echo "ℹ️ Tidak ada perubahan baru"
git push origin main

# 6. Rerun workflow
echo "⚡ Menjalankan ulang workflow android.yml..."
gh workflow run android.yml
sleep 5
LATEST=$(gh run list --workflow=android.yml --limit 1 --json databaseId -q '.[0].databaseId')
echo "ℹ️ Run ID terbaru: $LATEST"

# 7. Tunggu workflow selesai
echo "⏳ Menunggu build selesai..."
gh run watch $LATEST

# 8. Cek hasil build
if gh run view $LATEST --json conclusion -q '.conclusion' | grep -q "success"; then
  echo "✅ Build sukses tanpa error Kotlin/Gradle"
else
  echo "❌ Build gagal, error Kotlin/Gradle terakhir:"
  gh run view $LATEST --log | grep "e: " | tail -n 15
fi
