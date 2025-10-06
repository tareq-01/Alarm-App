import 'dart:async';

import 'package:alarm_app/services/app_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SplashScreenNotifier extends StateNotifier<dynamic> {
  final Ref ref;
  SplashScreenNotifier(this.ref) : super(0) {
    timeDuration();
  }
  void timeDuration() {
    Timer(Duration(seconds: 2), () => router.push("/home"));
  }
}

final splashScreenProvider =
    StateNotifierProvider<SplashScreenNotifier, dynamic>(
      (ref) => SplashScreenNotifier(ref),
    );
