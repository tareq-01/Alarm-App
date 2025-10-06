import 'dart:developer';

import 'package:alarm_app/providers/alarm/alarm_state.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

class AlarmPageNotifier extends StateNotifier<AlarmState> {
  AlarmPageNotifier(this.ref) : super(AlarmState());

  final Ref ref;
  TimeOfDay timeOfDay = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();

  String formattedTime = DateFormat("hh:mm a").format(DateTime.now());

  void toggleSwitch(int index) {
    final update = List<AlarmModel>.from(state.alarms!);
    log("Update $update".toString());
    update[index].isEnable = !(update[index].isEnable ?? true);
    state = state.copyWith(alarms: update);
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

  String days(int index) {
    var item = state.alarms![index];

    if (item.selectedDays.isEmpty) {
      return "Select Date";
    } else if (item.selectedDays.length == 7) {
      return "Everyday";
    }

    return item.selectedDays.map((dayMap) => dayMap.keys.first).join(', ');
  }
}

final alarmPageProvider = StateNotifierProvider<AlarmPageNotifier, AlarmState>(
  (ref) => AlarmPageNotifier(ref),
);
