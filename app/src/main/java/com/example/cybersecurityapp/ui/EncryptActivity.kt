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
