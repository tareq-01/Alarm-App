package com.example.alarm_app


import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.alarm_app/audio"
    private var audioManager: AudioManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAlarmStream" -> {
                    try {
                        // Set the audio stream to ALARM
                        volumeControlStream = AudioManager.STREAM_ALARM
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to set alarm stream", e.message)
                    }
                }
                "resetAudioStream" -> {
                    try {
                        // Reset to default (music stream)
                        volumeControlStream = AudioManager.STREAM_MUSIC
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to reset audio stream", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}