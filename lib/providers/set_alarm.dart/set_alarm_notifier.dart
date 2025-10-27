import 'dart:async';
import 'dart:developer';
import 'package:alarm_app/main2.dart';
import 'package:audio_session/audio_session.dart';
import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:alarm_app/providers/set_alarm.dart/set_alarm_state.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:alarm_app/services/constants/auth.dart';
import 'package:alarm_app/views/alarm/widgets/set_alarm_bottom_sheet_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../views/alarm/widgets/edit_alarm.dart';
import 'package:intl/intl.dart';

class SetAlarmNotifier extends StateNotifier<SetAlarmState> {
  SetAlarmNotifier(this.ref) : super(SetAlarmState()) {
    _initializeAudioPlayer();
  }
  TimeOfDay timeOfDay = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  String formattedTime = DateFormat("hh:mm a").format(DateTime.now());

  final Ref ref;
  int selectedIndex = 0;
  final TextEditingController teController = TextEditingController();

  final AlarmAudioPlayer _audioPlayer = AlarmAudioPlayer();
  static const platform = MethodChannel('com.example.alarm_app/audio');

  List<Map<String, dynamic>> weekdays = [
    {'Sat': DateTime.saturday},
    {'Sun': DateTime.sunday},
    {'Mon': DateTime.monday},
    {'Tue': DateTime.tuesday},
    {'Wed': DateTime.wednesday},
    {'Thu': DateTime.thursday},
    {'Fri': DateTime.friday},
  ];

  Future<void> _initializeAudioPlayer() async {
    try {
      await setAlarmAudio();

      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.duckOthers,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            usage: AndroidAudioUsage.alarm,
            flags: AndroidAudioFlags.audibilityEnforced,
          ),
        ),
      );
    } catch (e) {
      log('Error initializing audio player: $e');
    }
  }

  Future<void> setAlarmAudio() async {
    try {
      await platform.invokeMethod('setAlarmStream');
    } on PlatformException catch (e) {}
  }

  Future<void> playAlarmSound() async {
    await _audioPlayer.stop();
    await setAlarmAudio();
    await _audioPlayer.initializeAndPlay('assets/sounds/alarm1.mp3');
    // Navigator.pop(context);
  }

  void toggleVibrate() {
    state = state.copyWith(isVibrate: !state.isVibrate!);
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

  String? days(int index) {
final alarmPageNotifier = ref.read(alarmPageProvider.notifier);
    final alarms = alarmPageNotifier.state.alarms![index];

    if (state.selectedDays!.isEmpty) {
      return DateFormat('EEE, MMM d').format(DateTime.now());
    } else if (state.selectedDays!.length == 7) {
      return "everyday";
    } else {
      return alarms.selectedDays.map ((dayMap) => dayMap.keys.first).join(', ');
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
    final alarms = alarmPageNotifier.state.alarms ?? [];

    if (index < alarms.length) {
      final updatedAlarms = List<AlarmModel>.from(alarms);
      updatedAlarms.removeAt(index);

      alarmPageNotifier.state = alarmPageNotifier.state.copyWith(
        alarms: updatedAlarms,
      );
      await AuthUtility().saveAlarm(updatedAlarms);
    }
  }

  void saveAlarm(String text) async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);

    List<Map<String, dynamic>> finalSelectedDays = state.selectedDays ?? [];

    if (finalSelectedDays.isEmpty) {
      int today = DateTime.now().weekday;
      finalSelectedDays = [weekdays.firstWhere((day) => day.values.first == today)];
    }

    AlarmModel alarmModel = AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      dateTime: state.selectedTime ?? DateTime.now(),
      selectedDays: finalSelectedDays,
      title: teController.text.trim(),
      isEnable: true,
      isVibrate: state.isVibrate ?? true,
    );

    teController.clear();
    final updatedList = List<AlarmModel>.from(
      alarmPageNotifier.state.alarms ?? [],
    );

    updatedList.add(alarmModel);
    alarmPageNotifier.state = alarmPageNotifier.state.copyWith(
      alarms: updatedList,
    );

    await AuthUtility().saveAlarm(updatedList);
    await scheduleAlarm(alarmModel);

    resetData();
  }


  void updateAlarm() async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);
    final alarms = alarmPageNotifier.state.alarms ?? [];

    final index = alarms.indexWhere(
          (alarm) => alarm.id == state.editingAlarmId,
    );

    if (index != -1) {
      List<Map<String, dynamic>> finalSelectedDays = state.selectedDays ?? [];

      if (finalSelectedDays.isEmpty) {
        int today = DateTime.now().weekday;
        finalSelectedDays = [weekdays.firstWhere((day) => day.values.first == today)];
      }

      AlarmModel updatedAlarm = AlarmModel(
        id: state.editingAlarmId,
        dateTime: state.selectedTime ?? DateTime.now(),
        selectedDays: finalSelectedDays,
        title: teController.text.trim(),
        isEnable: state.isEnable ?? true,
        isVibrate: state.isVibrate ?? true,
      );

      final updatedList = List<AlarmModel>.from(alarms);
      updatedList[index] = updatedAlarm;

      alarmPageNotifier.state = alarmPageNotifier.state.copyWith(
        alarms: updatedList,
      );

      await AuthUtility().saveAlarm(updatedList);

      if (updatedAlarm.isEnable == true) {
        await scheduleAlarm(updatedAlarm);
      }
    }

    resetData();
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
      isVibrate: alarm.isVibrate,
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

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    final nextAlarmTime = getNextAlarmDateTime(alarm);
    final duration = nextAlarmTime.difference(DateTime.now());

    if (duration.inSeconds > 1) {
      Timer(duration, () {
        triggerAlarm(alarm);
      });
    }
  }

  void triggerAlarm(AlarmModel alarm) async {
   // showAlarmRingDialog(alarm);

    await playAlarmSound();
    state = state.copyWith(alarmRingId: alarm.id);
  }

  // void showAlarmRingDialog(AlarmModel alarm) {
  //   final alarm = router.routerDelegate.navigatorKey.currentContext;
  //
  //   if (alarm != null) {
  //     showModalBottomSheet(
  //       isScrollControlled: true,
  //       enableDrag: true,
  //       context: alarm,
  //       builder: (context) {
  //         return Padding(
  //           padding: EdgeInsets.only(
  //             bottom: MediaQuery.of(context).viewInsets.top,
  //           ),
  //           child: AlarmRingScreen(
  //             alarmTitle: 'Title',
  //             onStop: () async {
  //               await stopAlarm();
  //               Navigator.pop(context);
  //             },
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  Future<void> stopAlarm() async {
    await _audioPlayer.stop();
  }

  DateTime getNextAlarmDateTime(AlarmModel alarm) {
    final selectedDays = alarm.selectedDays;

    if (selectedDays.isEmpty) {
      final now = DateTime.now();
      final alarmTime = alarm.dateTime;

      DateTime todayAlarm = DateTime(now.year, now.month, now.day, alarmTime.hour, alarmTime.minute);

      if (now.isAfter(todayAlarm)) {
        return todayAlarm.add(Duration(days: 1));
      } else {
        return todayAlarm;
      }
    }

    List<String> dayNames = selectedDays
        .map((dayMap) => dayMap.keys.first.toString())
        .toList();

    return calculateAlarmDateTime(
      dayNames,
      alarm.dateTime.hour,
      alarm.dateTime.minute,
    );
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

  String getRemainingTime(AlarmModel alarm) {
    final now = DateTime.now();
    final nextAlarmTime = getNextAlarmDateTime(alarm);
    Duration diff = nextAlarmTime.difference(now);

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) {
      return "$days days $hours hr $minutes min";
    } else if (hours > 0) {
      return "$hours hr $minutes min";
    } else {
      return "$minutes min";
    }
  }

  DateTime fullAlarmTime(int weekday, int hour, int minute, DateTime now) {
    int currentWeekday = now.weekday;

    int daysToAdd = (weekday - currentWeekday) % 7;
    if (daysToAdd == 0) {
      final todayAlarm = DateTime(now.year, now.month, now.day, hour, minute);
      if (now.isAfter(todayAlarm)) {
        daysToAdd = 7;
      }
    }

    DateTime nextAlarmDate = DateTime(
      now.year,
      now.month,
      now.day + daysToAdd,
      hour,
      minute,
    );

    return nextAlarmDate;
  }
}

final setAlarmProvider = StateNotifierProvider<SetAlarmNotifier, SetAlarmState>(
      (ref) => SetAlarmNotifier(ref),
);