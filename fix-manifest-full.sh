#!/bin/bash
echo "🚀 Auto Fix Manifest untuk Semua Activities + Launcher"

MANIFEST_FILE="app/src/main/AndroidManifest.xml"

declare -a ACTIVITIES=(
  ".MainActivity"
  ".ui.LoginActivity"
  ".ui.DashboardActivity"
  ".ui.PasswordGeneratorActivity"
  ".ui.EncryptActivity"
)

for ACT in "${ACTIVITIES[@]}"; do
  if ! grep -q "$ACT" "$MANIFEST_FILE"; then
    echo "➕ Tambah $ACT..."
    sed -i "/<\/application>/i\        <activity android:name=\"$ACT\" />" "$MANIFEST_FILE"
  else
    echo "ℹ️ $ACT sudah ada"
  fi
done

# Pastikan MainActivity punya intent-filter MAIN + LAUNCHER
if ! grep -A3 "MainActivity" "$MANIFEST_FILE" | grep -q "MAIN"; then
  echo "➕ Tambah intent-filter ke MainActivity..."
  sed -i "/<activity android:name=\".MainActivity\">/a\
            <intent-filter>\
                <action android:name=\"android.intent.action.MAIN\" />\
                <category android:name=\"android.intent.category.LAUNCHER\" />\
            </intent-filter>" "$MANIFEST_FILE"
else
  echo "✅ MainActivity sudah punya intent-filter"
fi

# Commit & Push
echo "📦 Commit & Push..."
git add $MANIFEST_FILE
git commit -m "fix: ensure all Activities + MainActivity launcher"
git push origin main

echo "🎉 Semua Activities sudah dipastikan ada & MainActivity jadi launcher!"
