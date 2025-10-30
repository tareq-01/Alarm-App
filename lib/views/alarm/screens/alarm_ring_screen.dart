import 'dart:ui';
import 'package:alarm_app/providers/set_alarm.dart/set_alarm_notifier.dart';
import 'package:flutter/material.dart';

class AlarmRingingScreen extends StatelessWidget {
   const AlarmRingingScreen({super.key});
final String _stopPortName = 'alarm_stop_port';

 Future<void> stopAlarm() async {
  final sendPort = IsolateNameServer.lookupPortByName(_stopPortName);
  if (sendPort != null) {
    sendPort.send('STOP_ALARM');
    await alarmAudioPlayer.stop();
    IsolateNameServer.removePortNameMapping(_stopPortName);
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
              const SizedBox(height: 40),
              const Text(
                'ALARM!',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 20),
              Text(
                TimeOfDay.now().format(context),
                style: const TextStyle(fontSize: 36, color: Colors.white)
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => stopAlarm(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
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
                        fontWeight: FontWeight.bold
                      )
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