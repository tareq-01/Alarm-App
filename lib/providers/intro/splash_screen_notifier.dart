import 'dart:async';

import 'package:alarm_app/services/app_route.dart';
import 'package:riverpod/legacy.dart';

class SplashScreenNotifier extends StateNotifier<dynamic> {
  SplashScreenNotifier() : super(0) {
    timeDuration();
  }
  void timeDuration() {
    Timer(Duration(seconds: 2), () => router.push("/home"));
  }
}

final splashScreenProvider =
    StateNotifierProvider<SplashScreenNotifier, dynamic>(
      (ref) => SplashScreenNotifier(),
    );
