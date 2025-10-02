#!/bin/bash
echo "🛡️ Setup Encrypt/Decrypt Logic"

cat > app/src/main/java/com/example/cybersecurityapp/ui/EncryptActivity.kt <<'EOF'
package com.example.cybersecurityapp.ui

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R
import java.util.Base64

class EncryptActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_encrypt)

        val edtInput = findViewById<EditText>(R.id.edtInput)
        val edtOutput = findViewById<EditText>(R.id.edtOutput)
        val btnEncrypt = findViewById<Button>(R.id.btnEncrypt)
        val btnDecrypt = findViewById<Button>(R.id.btnDecrypt)

        btnEncrypt.setOnClickListener {
            val input = edtInput.text.toString()
            val encrypted = Base64.getEncoder().encodeToString(input.toByteArray())
            edtOutput.setText(encrypted)
        }

        btnDecrypt.setOnClickListener {
            val input = edtInput.text.toString()
            try {
                val decrypted = String(Base64.getDecoder().decode(input))
                edtOutput.setText(decrypted)
            } catch (e: Exception) {
                edtOutput.setText("❌ Invalid Input")
            }
        }
    }
}
EOF

cat > app/src/main/res/layout/activity_encrypt.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:padding="16dp"
    android:gravity="center"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <EditText
        android:id="@+id/edtInput"
        android:hint="Input Text"
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

    <EditText
        android:id="@+id/edtOutput"
        android:hint="Output"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"/>
</LinearLayout>
EOF

git add app/src/main/java/com/example/cybersecurityapp/ui/EncryptActivity.kt app/src/main/res/layout/activity_encrypt.xml
git commit -m "feat: add Encrypt/Decrypt logic"
git push origin main
