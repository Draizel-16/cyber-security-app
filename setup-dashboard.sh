#!/bin/bash
echo "🚀 Setup Dashboard Feature"
git pull origin main

# Tambahkan Activity Dashboard
cat > app/src/main/java/com/example/cybersecurityapp/ui/DashboardActivity.kt <<'EOK'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R

class DashboardActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard)
    }
}
EOK

# Tambahkan layout Dashboard
mkdir -p app/src/main/res/layout
cat > app/src/main/res/layout/activity_dashboard.xml <<'EOL'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical">

    <TextView
        android:text="Welcome to Cyber Security Dashboard"
        android:textSize="20sp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>
</LinearLayout>
EOL

git add .
git commit -m "feat: add Dashboard feature"
git push origin main
