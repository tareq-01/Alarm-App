import 'package:alarm/alarm.dart';
import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:alarm_app/providers/set_alarm.dart/set_alarm_state.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:alarm_app/services/constants/auth.dart';
import 'package:alarm_app/views/alarm/widgets/edit_alarm.dart';
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

  void toggleVibrate() {
    state = state.copyWith(isVibrate: state.isVibrate!);
  }

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

  void deleteAlarm(int index) async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);

    final updatedAlarms = List<AlarmModel>.from(
      alarmPageNotifier.state.alarms ?? [],
    );

    updatedAlarms.removeAt(index);
    alarmPageNotifier.state = alarmPageNotifier.state.copyWith(
      alarms: updatedAlarms,
    );
    await AuthUtility().saveAlarm(updatedAlarms);
    final alarmId = updatedAlarms[index].id;
    await Alarm.stop(alarmId!);
  }

  void saveAlarm(String text) async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);

    AlarmModel alarmModel = AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      dateTime: state.selectedTime ?? DateTime.now(),
      selectedDays: state.selectedDays ?? [],
      title: teController.text.trim(),
      isEnable: false,
    );
    teController.clear();
    final updatedList = List<AlarmModel>.from(
      alarmPageNotifier.state.alarms ?? [],
    );
    // list add
    updatedList.add(alarmModel);
    // ui update
    alarmPageNotifier.state = alarmPageNotifier.state.copyWith(
      alarms: updatedList,
    );
    // save to local
    await AuthUtility().saveAlarm(alarmPageNotifier.state.alarms ?? []);
    // alarm set
    await setAlarm(alarmModel);
  }

  void editAlarm(BuildContext context, AlarmModel alarm) async {
    // final alarmPageNotifier = ref.read(alarmPageProvider.notifier)
    state = state.copyWith(isEnable: alarm.isEnable,
      selectedDays: state.selectedDays ?? [],
    
    
    );
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditAlarmButton(),
        );
      },
    );
  }

  void resetData() {
    state = SetAlarmState();
    teController.clear();
  }

  void showDialog(BuildContext context) async {
    resetData();
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SetAlarmBottomSheetContent(),
        );
      },
    );
  }

  Future<void> setAlarm(AlarmModel alarm) async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);

    final alarmSettings = AlarmSettings(
      id: alarm.id!,
      dateTime: state.selectedTime ?? DateTime.now(),
      assetAudioPath: 'assets/sounds/alarm1.mp3',

      notificationSettings: NotificationSettings(
        title: teController.text.toString(),
        body: 'This is the body',
        stopButton: 'Stop',
      ),
      volumeSettings: VolumeSettings.fixed(),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }
}

final setAlarmProvider = StateNotifierProvider<SetAlarmNotifier, SetAlarmState>(
  (ref) => SetAlarmNotifier(ref),
);
