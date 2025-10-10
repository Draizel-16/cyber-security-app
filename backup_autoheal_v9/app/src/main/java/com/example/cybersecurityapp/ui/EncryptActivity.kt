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
