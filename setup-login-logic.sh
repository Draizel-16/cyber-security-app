#!/bin/bash
echo "🔑 Setup Google Sign-In Logic"

# Pastikan folder ada
mkdir -p app/src/main/java/com/example/cybersecurityapp/ui
mkdir -p app/src/main/res/layout

# Buat LoginActivity.kt
cat > app/src/main/java/com/example/cybersecurityapp/ui/LoginActivity.kt <<'EOF'
package com.example.cybersecurityapp.ui

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException

class LoginActivity : AppCompatActivity() {

    private lateinit var googleSignInClient: GoogleSignInClient
    private val RC_SIGN_IN = 9001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        // Konfigurasi Google Sign-In
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)

        findViewById<android.widget.Button>(R.id.btnGoogleSignIn).setOnClickListener {
            signIn()
        }
    }

    private fun signIn() {
        val signInIntent = googleSignInClient.signInIntent
        startActivityForResult(signInIntent, RC_SIGN_IN)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == RC_SIGN_IN) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            try {
                val account = task.getResult(ApiException::class.java)
                // Login sukses, pindah ke Dashboard
                startActivity(Intent(this, DashboardActivity::class.java))
                finish()
            } catch (e: ApiException) {
                e.printStackTrace()
            }
        }
    }
}
EOF

# Buat layout activity_login.xml
cat > app/src/main/res/layout/activity_login.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="24dp">

    <Button
        android:id="@+id/btnGoogleSignIn"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Sign in with Google" />

</LinearLayout>
EOF

# Git commit + push
git add .
git commit -m "feat: add Google Sign-In LoginActivity + layout"
git push origin main

echo "🎉 Google Sign-In LoginActivity berhasil ditambahkan & dipush ke GitHub!"
