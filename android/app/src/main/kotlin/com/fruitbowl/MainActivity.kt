package com.fruitbowl

import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Display
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterFragmentActivity
class HomeMainScreen : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Post the call to ensure the decor view is ready
            window.decorView.post {
                try {
                    setHighestRefreshRate()
                } catch (e: Exception) {
                    Log.e("MainActivity", "Error setting refresh rate in onCreate: ${e.message}", e)
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Optionally call it again on resume
            try {
                setHighestRefreshRate()
            } catch (e: Exception) {
                Log.e("MainActivity", "Error setting refresh rate in onResume: ${e.message}", e)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun setHighestRefreshRate() {
        // Retrieve the current display from the window's decor view.
        val display: Display? = window.decorView.display
        display?.let {
            // Select the display mode with the highest refresh rate.
            val bestMode = it.supportedModes.maxByOrNull { mode -> mode.refreshRate }
            bestMode?.let { mode ->
                // Update the window's attributes to use the selected display mode.
                val params = window.attributes
                params.preferredDisplayModeId = mode.modeId
                window.attributes = params
                Log.i("MainActivity", "Set refresh rate to ${mode.refreshRate} Hz")
            }
        }
    }
}