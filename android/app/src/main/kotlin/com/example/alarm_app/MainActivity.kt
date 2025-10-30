package com.example.alarm_app


import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.alarm_app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "scheduleAlarm") {
                val route = call.argument<String>("routerConfig") ?: "/alarmRingScreen"

                val intent = Intent(applicationContext, AlarmReceiver::class.java)
                intent.putExtra("route", route)

                val pendingIntent = PendingIntent.getBroadcast(
                    applicationContext,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    pendingIntent
                )
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
