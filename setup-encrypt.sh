#!/bin/bash
echo "🛡️ Setup Encrypt/Decrypt Feature"
git pull origin main

# Tambahkan Activity Encrypt/Decrypt
cat > app/src/main/java/com/example/cybersecurityapp/ui/EncryptActivity.kt <<'EOK'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R
import java.util.*

class EncryptActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_encrypt)

        val input = findViewById<EditText>(R.id.editTextInput)
        val result = findViewById<TextView>(R.id.txtResult)
        val btnEncrypt = findViewById<Button>(R.id.btnEncrypt)
        val btnDecrypt = findViewById<Button>(R.id.btnDecrypt)

        btnEncrypt.setOnClickListener {
            val text = input.text.toString()
            result.text = Base64.getEncoder().encodeToString(text.toByteArray())
        }

        btnDecrypt.setOnClickListener {
            val text = input.text.toString()
            result.text = String(Base64.getDecoder().decode(text))
        }
    }
}
EOK

# Tambahkan layout Encrypt/Decrypt
cat > app/src/main/res/layout/activity_encrypt.xml <<'EOL'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="16dp">

    <EditText
        android:id="@+id/editTextInput"
        android:hint="Enter text"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"/>

    <Button
        android:id="@+id/btnEncrypt"
        android:text="Encrypt"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>

    <Button
        android:id="@+id/btnDecrypt"
        android:text="Decrypt"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"/>

    <TextView
        android:id="@+id/txtResult"
        android:text="Result"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:paddingTop="20dp"/>
</LinearLayout>
EOL

git add .
git commit -m "feat: add Encrypt/Decrypt feature"
git push origin main
