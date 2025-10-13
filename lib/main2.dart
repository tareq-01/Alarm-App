import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AlarmService {
  static AudioPlayer? _audioPlayer;

  // Set alarm with custom audio configuration
  static Future<void> setAlarm({
    required int id,
    required DateTime dateTime,
    required String assetAudioPath,
    String notificationTitle = 'Alarm',
    String notificationBody = 'Your alarm is ringing!',
  }) async {
    // Use the alarm package for scheduling and notifications
    // but disable its audio
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: "assets/sounds/alarm1.mp3",
      loopAudio: false, // Disable alarm package audio
      vibrate: true,

      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0,
        fadeDuration: Duration(seconds: 5),
      ),
      notificationSettings: NotificationSettings( title: 'This is the title',
    body: 'This is the body',
    stopButton: 'Stop the alarm',
    icon: 'notification_icon',
    iconColor: Color(0xff862778),),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  // Play alarm sound using alarm volume
  static Future<void> playAlarmSound(String assetPath) async {
    try {
      // Configure audio session to use ALARM audio stream
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            usage: AndroidAudioUsage.alarm, // THIS IS THE KEY!
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
        ),
      );

      // Create and configure audio player
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setAsset(assetPath);
      await _audioPlayer!.setLoopMode(LoopMode.one);
      await _audioPlayer!.setVolume(1.0);

      // Play the alarm sound
      await _audioPlayer!.play();
    } catch (e) {
      print('Error playing alarm sound: $e');
    }
  }

  // Stop alarm sound
  static Future<void> stopAlarmSound() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
      await _audioPlayer!.dispose();
      _audioPlayer = null;
    }
  }

  // Stop alarm (both notification and sound)
  static Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
    await stopAlarmSound();
  }
}

// Example usage in your alarm screen
class AlarmRingingScreen extends StatefulWidget {
  final int alarmId;

  const AlarmRingingScreen({Key? key, required this.alarmId}) : super(key: key);

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  @override
  void initState() {
    super.initState();
    // Play alarm sound when screen appears
    AlarmService.playAlarmSound('assets/sounds/alarm1.mp3');
  }

  @override
  void dispose() {
    // Stop alarm sound when screen is disposed
    AlarmService.stopAlarmSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Alarm Ringing!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await AlarmService.stopAlarm(widget.alarmId);
                Navigator.of(context).pop();
              },
              child: const Text('Stop Alarm'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await AlarmService.stopAlarm(widget.alarmId);
                // Set snooze alarm (e.g., 5 minutes later)
                await AlarmService.setAlarm(
                  id: widget.alarmId,
                  dateTime: DateTime.now().add(const Duration(minutes: 5)),
                  assetAudioPath: 'assets/sounds/alarm1.mp3',
                );
                Navigator.of(context).pop();
              },
              child: const Text('Snooze (5 min)'),
            ),
          ],
        ),
      ),
    );
  }
}

// In your main app, listen for alarms
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen for alarm rings
    Alarm.ringStream.stream.listen((alarmSettings) {
      // Navigate to alarm ringing screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AlarmRingingScreen(alarmId: alarmSettings.id),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Alarm App')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Example: Set alarm for 5 seconds from now
              await AlarmService.setAlarm(
                id: 1,
                dateTime: DateTime.now().add(const Duration(seconds: 5)),
                assetAudioPath: 'assets/alarm.mp3',
              );
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Alarm set for 5 seconds')),
              // );
            },
            child: const Text('Set Test Alarm (5 sec)'),
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();

  runApp((MyApp()));
}
