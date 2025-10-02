#!/bin/bash
echo "🔐 Setup Password Generator Feature"
git pull origin main

# Tambahkan Activity Password Generator
cat > app/src/main/java/com/example/cybersecurityapp/ui/PasswordGeneratorActivity.kt <<'EOK'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R
import kotlin.random.Random

class PasswordGeneratorActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_password_generator)

        val result = findViewById<TextView>(R.id.txtPassword)
        val btn = findViewById<Button>(R.id.btnGenerate)

        btn.setOnClickListener {
            val chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()"
            val password = (1..12)
                .map { chars[Random.nextInt(chars.length)] }
                .joinToString("")
            result.text = password
        }
    }
}
EOK

# Tambahkan layout Password Generator
cat > app/src/main/res/layout/activity_password_generator.xml <<'EOL'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="16dp">

    <Button
        android:id="@+id/btnGenerate"
        android:text="Generate Password"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>

    <TextView
        android:id="@+id/txtPassword"
        android:text="Generated Password"
        android:textSize="18sp"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:paddingTop="20dp"/>
</LinearLayout>
EOL

git add .
git commit -m "feat: add Password Generator feature"
git push origin main
