package com.example.cybersecurityapp.ui

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R

class DashboardActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard)

        val statsView = findViewById<TextView>(R.id.tvStats)
        statsView.text = "🔐 Total Password Tersimpan: 12\n🛡️ Data Terenkripsi: 8"
    }
}
