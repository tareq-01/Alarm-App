import 'dart:developer';

import 'package:alarm_app/main.dart';
import 'package:alarm_app/views/alarm/screens/alarm_ring_screen.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class AlarmAudioPlayer {
  AudioPlayer _player = AudioPlayer();
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

  Future<void> stop() async {
 await _player.stop();
        await _player.dispose();
            log("Stopping alarm");

  }

  // Future<void> _resetAudioStream() async {
  //   try {
  //     await platform.invokeMethod('resetAudioStream');
  //   } on PlatformException catch (e) {}
  // }
}
