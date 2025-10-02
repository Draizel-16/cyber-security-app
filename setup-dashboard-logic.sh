#!/bin/bash
echo "🚀 Setup Dashboard Logic"

cat > app/src/main/java/com/example/cybersecurityapp/ui/DashboardActivity.kt <<'EOF'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R

class DashboardActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard)

        val statsView = findViewById<TextView>(R.id.tvStats)
        statsView.text = "🔐 Total Password Tersimpan: 12\n🛡️ Data Terenkripsi: 8"
    }
}
EOF

cat > app/src/main/res/layout/activity_dashboard.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:padding="16dp"
    android:gravity="center"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:id="@+id/tvStats"
        android:text="Loading..."
        android:textSize="18sp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>
</LinearLayout>
EOF

git add app/src/main/java/com/example/cybersecurityapp/ui/DashboardActivity.kt app/src/main/res/layout/activity_dashboard.xml
git commit -m "feat: add DashboardActivity logic (dummy stats)"
git push origin main
