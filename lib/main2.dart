// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Alarm App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: AlarmScreen(),
    );
  }
}

// ===================================================
// lib/screens/alarm_screen.dart

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final AlarmAudioPlayer _audioPlayer = AlarmAudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alarm Audio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _audioPlayer.initializeAndPlay('assets/sounds/alarm1.mp3');
              },
              child: Text('Play Alarm'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _audioPlayer.stop();
              },
              child: Text('Stop Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================
// lib/services/alarm_audio_player.dart

class AlarmAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  static const platform = MethodChannel('com.example.alarm_app/audio');

  Future<void> initializeAndPlay(String audioPath) async {
    try {
      // Set audio stream to ALARM via platform channel
      await _setAlarmAudioStream();

      // Configure audio session
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            usage: AndroidAudioUsage.alarm,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        ),
      );

      // Load and play audio
      await _player.setAsset(audioPath);
      await _player.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _setAlarmAudioStream() async {
    try {
      await platform.invokeMethod('setAlarmStream');
    } on PlatformException catch (e) {
      print("Failed to set alarm stream: '${e.message}'.");
    }
  }

  Future<void> stop() async {
    await _player.stop();
    await _resetAudioStream();
  }

  Future<void> _resetAudioStream() async {
    try {
      await platform.invokeMethod('resetAudioStream');
    } on PlatformException catch (e) {
      print("Failed to reset audio stream: '${e.message}'.");
    }
  }

  void dispose() {
    _player.dispose();
  }
}


