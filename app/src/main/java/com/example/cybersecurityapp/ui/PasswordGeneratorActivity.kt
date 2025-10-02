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
