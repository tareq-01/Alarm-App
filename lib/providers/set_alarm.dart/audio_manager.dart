import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class AlarmAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  static const platform = MethodChannel('com.example.alarm_app');

  Future<void> initializeAndPlay(String audioPath) async {
    try {
     // await _setAlarmAudioStream();

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
      log(e.toString());
    }
  }

  Future<void> _setAlarmAudioStream() async {
    try {
      await platform.invokeMethod('setAlarmStream');
    } on PlatformException catch (e) {}
  }

  Future<void> stop() async {
    await _player.stop();
    //await _resetAudioStream();
  }

  Future<void> _resetAudioStream() async {
    try {
      await platform.invokeMethod('resetAudioStream');
    } on PlatformException catch (e) {}
  }
}
