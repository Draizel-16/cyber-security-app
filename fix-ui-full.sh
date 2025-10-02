#!/bin/bash
echo "🚀 Auto Fix UI + Features + Manifest"

# Path
UI_DIR="app/src/main/java/com/example/cybersecurityapp/ui"
LAYOUT_DIR="app/src/main/res/layout"
MANIFEST_FILE="app/src/main/AndroidManifest.xml"

# Pastikan folder ada
mkdir -p $UI_DIR
mkdir -p $LAYOUT_DIR

# === Generate Activities ===
cat > $UI_DIR/DashboardActivity.kt <<'EOF'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R

class DashboardActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard)
        title = "Dashboard"
    }
}
EOF

cat > $UI_DIR/PasswordGeneratorActivity.kt <<'EOF'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R

class PasswordGeneratorActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_password_generator)
        title = "Password Generator"
    }
}
EOF

cat > $UI_DIR/EncryptActivity.kt <<'EOF'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R

class EncryptActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_encrypt)
        title = "Encrypt/Decrypt"
    }
}
EOF

# === Generate Layouts ===
cat > $LAYOUT_DIR/activity_dashboard.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:gravity="center"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:text="Dashboard Screen"
        android:textSize="20sp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>
</LinearLayout>
EOF

cat > $LAYOUT_DIR/activity_password_generator.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:gravity="center"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:text="Password Generator Screen"
        android:textSize="20sp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>
</LinearLayout>
EOF

cat > $LAYOUT_DIR/activity_encrypt.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:gravity="center"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:text="Encrypt/Decrypt Screen"
        android:textSize="20sp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>
</LinearLayout>
EOF

# === Tambahkan ke AndroidManifest.xml ===
if grep -q "DashboardActivity" $MANIFEST_FILE; then
  echo "ℹ️ Activities sudah ada di AndroidManifest.xml"
else
  sed -i '/<\/application>/i\
        <activity android:name=".ui.DashboardActivity" />\
        <activity android:name=".ui.PasswordGeneratorActivity" />\
        <activity android:name=".ui.EncryptActivity" />' $MANIFEST_FILE
  echo "✅ Activities ditambahkan ke AndroidManifest.xml"
fi

# === Git Commit & Push ===
git add $UI_DIR/*.kt $LAYOUT_DIR/*.xml $MANIFEST_FILE
git commit -m "fix: auto-generate Activities + Layouts + Manifest entries"
git push origin main

echo "🎉 Semua Activities + Layouts + Manifest sudah dibuat & dipush ke GitHub!"
