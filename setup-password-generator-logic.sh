#!/bin/bash
echo "🔐 Setup Password Generator Logic"

cat > app/src/main/java/com/example/cybersecurityapp/ui/PasswordGeneratorActivity.kt <<'EOF'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R
import kotlin.random.Random

class PasswordGeneratorActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_password_generator)

        val edtPassword = findViewById<EditText>(R.id.edtPassword)
        val btnGenerate = findViewById<Button>(R.id.btnGenerate)

        btnGenerate.setOnClickListener {
            val chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()"
            val password = (1..12).map { chars.random() }.joinToString("")
            edtPassword.setText(password)
        }
    }
}
EOF

cat > app/src/main/res/layout/activity_password_generator.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:padding="16dp"
    android:gravity="center"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <EditText
        android:id="@+id/edtPassword"
        android:hint="Generated Password"
        android:textSize="18sp"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"/>

    <Button
        android:id="@+id/btnGenerate"
        android:text="Generate Password"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>
</LinearLayout>
EOF

git add app/src/main/java/com/example/cybersecurityapp/ui/PasswordGeneratorActivity.kt app/src/main/res/layout/activity_password_generator.xml
git commit -m "feat: add Password Generator logic"
git push origin main
