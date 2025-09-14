package com.rmac.multitimer

import android.content.Context
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val HAPTIC_CHANNEL = "flutter/haptic_feedback"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HAPTIC_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    val duration = call.argument<Int>("duration") ?: 50
                    performVibration(duration.toLong())
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun performVibration(duration: Long) {
        try {
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            
            if (vibrator.hasVibrator()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    // Use VibrationEffect for Android 8.0+
                    val effect = VibrationEffect.createOneShot(duration, VibrationEffect.DEFAULT_AMPLITUDE)
                    vibrator.vibrate(effect)
                } else {
                    // Fallback for older Android versions
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(duration)
                }
            }
        } catch (e: Exception) {
            // Ignore vibration errors
        }
    }
}
