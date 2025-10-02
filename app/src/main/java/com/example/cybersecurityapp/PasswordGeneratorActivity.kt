package com.example.cybersecurityapp

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import kotlin.random.Random

class PasswordGeneratorActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_password_generator)

        val txtResult = findViewById<TextView>(R.id.txtPassword)
        val btnGenerate = findViewById<Button>(R.id.btnGenerate)
        val edtLength = findViewById<EditText>(R.id.edtLength)

        btnGenerate.setOnClickListener {
            val length = edtLength.text.toString().toIntOrNull() ?: 12
            val chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()"
            val password = (1..length)
                .map { chars[Random.nextInt(chars.length)] }
                .joinToString("")
            txtResult.text = password
        }
    }
}
