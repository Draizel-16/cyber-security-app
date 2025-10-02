#!/bin/bash
echo "🚀 Auto Fix Build Errors (UI + Dependencies)"

# 1. Tambahkan dependency Google Sign-In
echo "📦 Tambah dependency Google Sign-In ke build.gradle..."
if ! grep -q "play-services-auth" app/build.gradle; then
  sed -i '/implementation "androidx.appcompat:appcompat/a \    implementation "com.google.android.gms:play-services-auth:20.7.0"' app/build.gradle
  echo "✅ Dependency play-services-auth ditambahkan"
else
  echo "ℹ️ Dependency sudah ada"
fi

# 2. Patch layout activity_encrypt.xml
LAYOUT_ENCRYPT="app/src/main/res/layout/activity_encrypt.xml"
if [ -f "$LAYOUT_ENCRYPT" ]; then
  if ! grep -q "txtOutput" "$LAYOUT_ENCRYPT"; then
    echo "➕ Tambah txtOutput ke activity_encrypt.xml..."
    sed -i '/<\/LinearLayout>/i \    <TextView\n        android:id="@+id/txtOutput"\n        android:layout_width="match_parent"\n        android:layout_height="wrap_content"\n        android:text="Output"\n        android:textSize="16sp"/>' "$LAYOUT_ENCRYPT"
  fi
else
  echo "❌ $LAYOUT_ENCRYPT tidak ditemukan"
fi

# 3. Patch layout activity_password_generator.xml
LAYOUT_PASS="app/src/main/res/layout/activity_password_generator.xml"
if [ -f "$LAYOUT_PASS" ]; then
  if ! grep -q "txtPassword" "$LAYOUT_PASS"; then
    echo "➕ Tambah txtPassword ke activity_password_generator.xml..."
    sed -i '/<\/LinearLayout>/i \    <TextView\n        android:id="@+id/txtPassword"\n        android:layout_width="match_parent"\n        android:layout_height="wrap_content"\n        android:text="Generated Password"\n        android:textSize="16sp"/>' "$LAYOUT_PASS"
  fi
  if ! grep -q "edtLength" "$LAYOUT_PASS"; then
    echo "➕ Tambah edtLength ke activity_password_generator.xml..."
    sed -i '/<\/LinearLayout>/i \    <EditText\n        android:id="@+id/edtLength"\n        android:layout_width="match_parent"\n        android:layout_height="wrap_content"\n        android:hint="Password Length"\n        android:inputType="number"/>' "$LAYOUT_PASS"
  fi
else
  echo "❌ $LAYOUT_PASS tidak ditemukan"
fi

# 4. Commit & Push
echo "📦 Commit & Push perubahan..."
git add app/build.gradle app/src/main/res/layout/
git commit -m "fix: add Google Sign-In dependency + patch missing views"
git push origin main

echo "🎉 Fix selesai! Silakan rerun workflow."
