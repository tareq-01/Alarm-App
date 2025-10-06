import 'dart:developer';

import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:alarm_app/providers/set_alarm.dart/set_alarm_state.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:alarm_app/views/alarm/widgets/set_alarm_bottom_sheet_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetAlarmNotifier extends StateNotifier<SetAlarmState> {
  SetAlarmNotifier(this.ref) : super(SetAlarmState());
  final Ref ref;
  int selectedIndex = 0;
  final TextEditingController teController = TextEditingController();
  List<Map<String, dynamic>> weekdays = [
    {'Sat': DateTime.monday},
    {'Sun': DateTime.tuesday},
    {'Mon': DateTime.wednesday},
    {'Tue': DateTime.thursday},
    {'Wed': DateTime.friday},
    {'Thu': DateTime.saturday},
    {'Fri': DateTime.sunday},
  ];

  void selectedDay(Map<String, dynamic> item) {
    List<Map<String, dynamic>> selectedDayList = List.from(
      state.selectedDays ?? [],
    );

    if (selectedDayList.isEmpty) {
      selectedDayList.add(item);
    } else {
      bool checkValue = selectedDayList.any(
        (element) => element.keys.first == item.keys.first,
      );
      if (checkValue) {
        selectedDayList.removeWhere(
          (element) => element.keys.first == item.keys.first,
        );
      } else {
        selectedDayList.add(item);
      }


    }

    state = state.copyWith(selectedDays: selectedDayList);
  }

  String day(int index) {
    return weekdays[index].keys.first;
  }

  String? days() {
    if (state.selectedDays!.isEmpty) {
      return "Select Day";
    } else if (state.selectedDays!.length == 7) {
      return "everyday";
    } else {
      return state.selectedDays!.map((dayMap) => dayMap.keys.first).join(', ');
    }
  }

  Future<void> showTime(BuildContext context) async {
    final currentTime = state.selectedTime ?? DateTime.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute,
      ),
    );
    if (picked != null) {
      state = state.copyWith(
        selectedTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          picked.hour,
          picked.minute,
        ),
      );
    }
  }

  void saveAlarm(String text) {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);

    AlarmModel alarmModel = AlarmModel(
      dateTime: state.selectedTime ?? DateTime.now(),
      selectedDays: state.selectedDays ?? [],
      title: teController.text.trim(),

      isEnable: true,
    );
    teController.clear();
    final updatedList = List<AlarmModel>.from(
      alarmPageNotifier.state.alarms ?? [],
    );
    updatedList.add(alarmModel);
    alarmPageNotifier.state = alarmPageNotifier.state.copyWith(
      alarms: updatedList,
    );

    log(alarmPageNotifier.state.alarms.toString());
  }

  void showDialouge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SetAlarmBottomSheetContent();
      },
    );
  }
}

final setAlarmProvider = StateNotifierProvider<SetAlarmNotifier, SetAlarmState>(
  (ref) => SetAlarmNotifier(ref),
);
