import 'dart:developer';

import 'package:alarm_app/providers/set_alarm.dart/set_alarm_state.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:alarm_app/views/alarm/widgets/set_alarm_bottom_sheet_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class SetAlarmNotifier extends StateNotifier<SetAlarmState> {
  SetAlarmNotifier() : super(SetAlarmState());
  int selectedIndex = 0;
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

      // for (var value in selectedDayList) {
      //   bool checkValue = value.containsKey(item.keys.first);
      //   if (checkValue) {
      //     selectedDayList.remove(value);
      //   } else {
      //     selectedDayList.add(value);
      //   }
      //   log("SelectedList $selectedDayList".toString());
      // }
    }

    // String dayKey = state.selectedDays![index].keys.first;

    // if (selectedDays.contains(dayKey)) {
    //   selectedDays.remove(dayKey);
    // } else {
    //   selectedDays.add(dayKey);
    // }
    log(" select1${selectedDayList}".toString());

    state = state.copyWith(selectedDays: selectedDayList);
    log(" select2${state.selectedDays}".toString());
  }

  String day(int index) {
    return weekdays[index].keys.first;
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

  void saveAlarm() {
    AlarmModel alarmModel = AlarmModel(
      dateTime: state.selectedTime ?? DateTime.now(),
      selectedDays: state.selectedDays ?? [],
    );

 
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
  (ref) => SetAlarmNotifier(),
);
