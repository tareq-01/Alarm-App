import 'dart:async';

import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:alarm_app/services/app_route.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:alarm_app/services/constants/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreenNotifier extends StateNotifier<dynamic> {
  final Ref ref;
  SplashScreenNotifier(this.ref) : super(0) {
    timeDuration();
  }
  void timeDuration() async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);
  List<AlarmModel> alarmList=  await AuthUtility().getAlarm();
    state = state.copyWith(alarms: alarmList);
    Timer(Duration(seconds: 2), () => router.push("/home"));
  }
}

final splashScreenProvider =
    StateNotifierProvider<SplashScreenNotifier, dynamic>(
      (ref) => SplashScreenNotifier(ref),
    );
