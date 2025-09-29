import 'package:alarm_app/providers/set_alarm.dart/set_alarm_state.dart';
import 'package:alarm_app/views/alarm/widgets/set_alarm_bottom_sheet_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class SetAlarmNotifier extends StateNotifier<SetAlarmState> {
  SetAlarmNotifier() : super(SetAlarmState());

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
