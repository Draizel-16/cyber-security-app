package com.example.cybersecurityapp

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import java.util.*
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec

class EncryptActivity : AppCompatActivity() {
    private val secretKey = "MySecretKey12345" // 16 chars

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_encrypt)

        val edtInput = findViewById<EditText>(R.id.edtInput)
        val txtOutput = findViewById<TextView>(R.id.txtOutput)
        val btnEncrypt = findViewById<Button>(R.id.btnEncrypt)
        val btnDecrypt = findViewById<Button>(R.id.btnDecrypt)

        btnEncrypt.setOnClickListener {
            val input = edtInput.text.toString()
            txtOutput.text = encrypt(input)
        }

        btnDecrypt.setOnClickListener {
            val input = edtInput.text.toString()
            txtOutput.text = decrypt(input)
        }
    }

    private fun encrypt(data: String): String {
        val cipher = Cipher.getInstance("AES")
        val keySpec = SecretKeySpec(secretKey.toByteArray(), "AES")
        cipher.init(Cipher.ENCRYPT_MODE, keySpec)
        return Base64.getEncoder().encodeToString(cipher.doFinal(data.toByteArray()))
    }

    private fun decrypt(data: String): String {
        val cipher = Cipher.getInstance("AES")
        val keySpec = SecretKeySpec(secretKey.toByteArray(), "AES")
        cipher.init(Cipher.DECRYPT_MODE, keySpec)
        return String(cipher.doFinal(Base64.getDecoder().decode(data)))
    }
}
