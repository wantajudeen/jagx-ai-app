package com.jagx.ai

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.jagx.ai.ui.JagXApp
import com.jagx.ai.ui.theme.JagXTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            JagXTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    JagXApp()
                }
            }
        }
    }
}
