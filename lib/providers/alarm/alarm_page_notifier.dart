import 'package:alarm_app/providers/alarm/alarm_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

class AlarmPageNotifier extends StateNotifier<AlarmState> {
  AlarmPageNotifier() : super(AlarmState());


  TimeOfDay timeOfDay = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  //TimeOfDay.fromDateTime(DateTime time);
  //int Selectedindex = -1;

  String formattedTime = DateFormat("hh:mm a").format(DateTime.now());

  void selected(bool value) {
    state = state.copyWith(isEnable: !state.isEnable!);
  }

  Future<void> showTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (picked != null) {
      timeOfDay = picked;
    }
  }
}

final alarmPageProvider = StateNotifierProvider<AlarmPageNotifier, AlarmState>(
  (ref) => AlarmPageNotifier(),
);
