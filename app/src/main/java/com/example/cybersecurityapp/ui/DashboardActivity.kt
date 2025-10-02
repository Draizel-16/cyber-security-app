package com.example.cybersecurityapp.ui

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.cybersecurityapp.R

class DashboardActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard)
        title = "Dashboard"
    }
}
