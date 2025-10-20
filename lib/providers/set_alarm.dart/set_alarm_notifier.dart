import 'dart:developer';
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
    {'Sat': DateTime.saturday},
    {'Sun': DateTime.sunday},
    {'Mon': DateTime.monday},
    {'Tue': DateTime.tuesday},
    {'Wed': DateTime.wednesday},
    {'Thu': DateTime.thursday},
    {'Fri': DateTime.friday},
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
      isEnable: state.isEnable!,
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
    state = state.copyWith(
      isEnable: alarm.isEnable,
      selectedDays: alarm.selectedDays
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      selectedTime: alarm.dateTime,
      editingAlarmId: alarm.id,
      title: alarm.title,
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

  void updateAlarm() async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);

    final updatedList = List<AlarmModel>.from(
      alarmPageNotifier.state.alarms ?? [],
    );

    final index = updatedList.indexWhere(
      (alarm) => alarm.id == state.editingAlarmId,
    );
    final removePreviousAlarm = updatedList[index].id;

    await Alarm.stop(removePreviousAlarm!);

    AlarmModel updatedAlarm = AlarmModel(
      id: state.editingAlarmId,
      dateTime: state.selectedTime ?? DateTime.now(),
      selectedDays: state.selectedDays ?? [],
      title: teController.text.trim(),
      isEnable: state.isEnable,
    );

    updatedList[index] = updatedAlarm;

    alarmPageNotifier.state = alarmPageNotifier.state.copyWith(
      alarms: updatedList,
    );

    await AuthUtility().saveAlarm(updatedList);

    await setAlarm(updatedAlarm);
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
    final selectedDays = alarm.selectedDays;

    List<String> dayNames = selectedDays
        .map((dayMap) => dayMap.keys.first.toString())
        .toList();


    DateTime nextAlarmDateTime = calculateAlarmDateTime(
      dayNames,
      alarm.dateTime.hour,
      alarm.dateTime.minute,
    );

    final alarmSettings = AlarmSettings(
      id: alarm.id!,
      dateTime: nextAlarmDateTime,
      assetAudioPath: 'assets/sounds/alarm1.mp3',
      notificationSettings: NotificationSettings(
        title: alarm.title ?? 'Alarm',
        body: 'Time to wake up!',
        stopButton: 'Stop',
      ),
      volumeSettings: VolumeSettings.fixed(),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    alarmListener();
  }



  DateTime calculateAlarmDateTime(
    List<String> selectedDays,
    int hour,
    int minute,
  ) {
    final weekdayMap = {
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
    };

    DateTime now = DateTime.now();
    List<int> selectedWeekdays = selectedDays
        .map((day) => weekdayMap[day]!)
        .toList();

    int currentWeekday = now.weekday;
    bool isCurrentDaySelected = selectedWeekdays.contains(currentWeekday);

    DateTime todayAlarm = DateTime(now.year, now.month, now.day, hour, minute);

    if (isCurrentDaySelected) {
      if (now.isBefore(todayAlarm)) {
        return todayAlarm;
      } else {
        return findNextAlarmDate(
          selectedWeekdays,
          currentWeekday,
          hour,
          minute,
          now,
        );
      }
    } else {
      return findNextAlarmDate(
        selectedWeekdays,
        currentWeekday,
        hour,
        minute,
        now,
      );
    }
  }

  DateTime findNextAlarmDate(
    List<int> selectedWeekdays,
    int currentWeekday,
    int hour,
    int minute,
    DateTime now,
  ) {
    selectedWeekdays.sort();

    for (int day in selectedWeekdays) {
      if (day > currentWeekday) {
        int daysToAdd = day - currentWeekday;
        return DateTime(now.year, now.month, now.day + daysToAdd, hour, minute);
      }
    }

    int firstWeekday = selectedWeekdays.first;
    int daysToAdd = (7 - currentWeekday) + firstWeekday;

    return DateTime(now.year, now.month, now.day + daysToAdd, hour, minute);
  }

  String getDayName(int weekday) {
    final dayNames = {
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
    };
    return dayNames[weekday]!;
  }

void alarmListener() {
  Alarm.ringStream.stream.listen((alarmSettings) {
    log("Alarm is ringing: ${alarmSettings.id}");
  });
}

void newAlarm(int id) async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);
  final alarms = alarmPageNotifier.state.alarms ?? [];

  final ringingAlarm = alarms.firstWhere(
    (alarm) => alarm.id == id,
    orElse: () => AlarmModel(),
  );

  if (ringingAlarm.id == null) {
    log("No alarm found for id: $id");
    return;
  }

  final selectedDays = ringingAlarm.selectedDays ?? [];

  if (selectedDays.isEmpty) {
    log("Alarm ${ringingAlarm.id} has no repeat days, stopping.");
    return;
  }

  final weekdayMap = {
    'Sat': DateTime.saturday,
    'Sun': DateTime.sunday,
    'Mon': DateTime.monday,
    'Tue': DateTime.tuesday,
    'Wed': DateTime.wednesday,
    'Thu': DateTime.thursday,
    'Fri': DateTime.friday,
  };

  final selectedWeekdays = selectedDays
      .map((dayMap) => weekdayMap[dayMap.keys.first]!)
      .toList();





}

}




final setAlarmProvider = StateNotifierProvider<SetAlarmNotifier, SetAlarmState>(
  (ref) => SetAlarmNotifier(ref),
);
