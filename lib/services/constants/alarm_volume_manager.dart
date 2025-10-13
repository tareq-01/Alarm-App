import 'package:alarm/alarm.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmVolumeManager {
  static final AlarmVolumeManager _instance = AlarmVolumeManager._internal();
  factory AlarmVolumeManager() => _instance;
  AlarmVolumeManager._internal();

  double? _previousVolume;

  Future<void> setAlarm(AlarmModel alarm) async {
    // Get current system alarm volume
    

    // Get user's preferred alarm volume from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final alarmVolume = prefs.getDouble('alarm_volume_${alarm.id}') ?? 0.8;

    // Set system alarm volume
    await FlutterVolumeController.setVolume(
      alarmVolume,
      stream: AudioStream.alarm,
    );

    // Alarm settings
    final alarmSettings = AlarmSettings(
      id: alarm.id!,
      dateTime: alarm.dateTime,
      assetAudioPath: 'assets/sounds/alarm1.mp3',
      warningNotificationOnKill: false,
      androidFullScreenIntent: false,
      allowAlarmOverlap: true,
      iOSBackgroundAudio: false,
      androidStopAlarmOnTermination: true,
      notificationSettings: NotificationSettings(
        title: alarm.title.toString(),
        body: 'Alarm notification',
        stopButton: 'Stop',
      ),
      volumeSettings: VolumeSettings.fixed(), // Use system alarm volume
    );

    // Set alarm
    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> startAlarmWithVolume(int alarmId) async {
    // Save current system alarm volume
    _previousVolume = await FlutterVolumeController.getVolume(
      stream: AudioStream.alarm,
    );

    // Get alarm-specific volume
    final prefs = await SharedPreferences.getInstance();
    final alarmVolume = prefs.getDouble('alarm_volume_$alarmId') ?? 0.8;

    // Set system alarm volume
    await FlutterVolumeController.setVolume(
      alarmVolume,
      stream: AudioStream.alarm,
    );
  }

  Future<void> stopAlarmAndRestoreVolume(int alarmId) async {
    // Stop the alarm
    await Alarm.stop(alarmId);

    // Restore previous system alarm volume
    if (_previousVolume != null) {
      await FlutterVolumeController.setVolume(
        _previousVolume!,
        stream: AudioStream.alarm,
      );
      _previousVolume = null;
    }
  }

  Future<void> setAlarmVolume(int alarmId, double volume) async {
    // Save alarm-specific volume to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('alarm_volume_$alarmId', volume);
  }

  Future<double> getAlarmVolume(int alarmId) async {
    // Get alarm-specific volume from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('alarm_volume_$alarmId') ?? 0.8;
  }

  Future<void> setPreviewVolume(double volume) async {
    // Set system alarm volume for preview
    await FlutterVolumeController.setVolume(volume, stream: AudioStream.ring);
  }

  Future<double> getCurrentVolume() async {
    // Get current system alarm volume
    return await FlutterVolumeController.getVolume(stream: AudioStream.alarm) ??
        0.5;
  }

  Future<void> restorePreviousVolume() async {
    if (_previousVolume != null) {
      await FlutterVolumeController.setVolume(
        _previousVolume!,
        stream: AudioStream.alarm,
      );
      _previousVolume = null;
    }
  }

  // Listen to system alarm volume changes
  Future<void> listenToAlarmVolume() async {
    //return FlutterVolumeController.listener.map((event) => event);

    await FlutterVolumeController.addListener((volume) => volume);
  }
}
