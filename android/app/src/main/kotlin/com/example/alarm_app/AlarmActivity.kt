package com.example.alarm_app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.view.WindowManager

class AlarmActivity : FlutterActivity() {
    override fun getInitialRoute(): String? {
        return intent?.getStringExtra("route") ?: "/alarmRingScreen"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
    }
}
