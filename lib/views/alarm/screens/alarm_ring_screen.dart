import 'package:alarm_app/providers/set_alarm.dart/set_alarm_notifier.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmRingingScreen extends StatefulWidget {
   const AlarmRingingScreen({super.key,});
  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _stopAlarm() async {
    // Cancel the notification
    await flutterLocalNotificationsPlugin.cancel(0);

    // Cancel the alarm
    await AndroidAlarmManager.cancel(0);

    // Update alarm state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_set', false);

    // Close the screen
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_controller.value * 0.2),
                    child: const Icon(
                      Icons.alarm,
                      size: 150,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'ALARM!',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                TimeOfDay.now().format(context),
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: _stopAlarm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stop_circle, size: 32),
                    SizedBox(width: 10),
                    Text(
                      'STOP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
