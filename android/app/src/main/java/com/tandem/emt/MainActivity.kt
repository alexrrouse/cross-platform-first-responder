package com.tandem.emt

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.tandem.emt.navigation.AppNavigation
import com.tandem.emt.ui.theme.TandemEMTTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            TandemEMTTheme {
                AppNavigation()
            }
        }
    }
}
