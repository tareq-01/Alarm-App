import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:alarm_app/providers/set_alarm.dart/audio_manager.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:alarm_app/providers/set_alarm.dart/set_alarm_state.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:alarm_app/services/constants/auth.dart';
import 'package:alarm_app/views/alarm/widgets/set_alarm_bottom_sheet_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../views/alarm/widgets/edit_alarm.dart';
import 'package:intl/intl.dart';

AlarmAudioPlayer alarmAudioPlayer = AlarmAudioPlayer();
const String _stopPortName = 'alarm_stop_port';
const platform = MethodChannel('com.example.alarm_app');

@pragma('vm:entry-point')
void alarmCallback(int alarmId) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(_stopPortName);
  IsolateNameServer.registerPortWithName(port.sendPort, _stopPortName);

  port.listen((message) {
    if (message == 'STOP_ALARM') {
      alarmAudioPlayer.stop();
      IsolateNameServer.removePortNameMapping(_stopPortName);
    }
  });

  notificationsInitialize();

  await flutterLocalNotificationsPlugin.show(
    alarmId,
    "Alarm",
    "Time to wake up!",
    NotificationDetails(
      android: AndroidNotificationDetails(
        "instant_notifications_channel_id",
        "Instant Notifications",
        channelDescription: "Instant notifications channel",
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        playSound: false,

        actions: [AndroidNotificationAction('ACTION_ACCEPT', 'Stop', showsUserInterface: true, cancelNotification: true)],
      ),
    ),
    payload: 'alarm_screen',
  );

  // Play alarm sound
  await alarmAudioPlayer.initializeAndPlay("assets/sounds/alarm2.mp3");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class SetAlarmNotifier extends StateNotifier<SetAlarmState> {
  SetAlarmNotifier(this.ref) : super(SetAlarmState()) {
    AndroidAlarmManager.initialize();
  }
  TimeOfDay timeOfDay = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();

  final Ref ref;
  int selectedIndex = 0;
  final TextEditingController teController = TextEditingController();

  static const platform = MethodChannel("com.example.alarm_app");

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
    state = state.copyWith(isVibrate: !state.isVibrate!);
  }

  void selectedDay(Map<String, dynamic> item) {
    List<Map<String, dynamic>> selectedDayList = List.from(state.selectedDays ?? []);

    if (selectedDayList.isEmpty) {
      selectedDayList.add(item);
    } else {
      bool checkValue = selectedDayList.any((element) => element.keys.first == item.keys.first);
      if (checkValue) {
        selectedDayList.removeWhere((element) => element.keys.first == item.keys.first);
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
    if (alarms.selectedDays.isEmpty) {
      return DateFormat('EEE').format(DateTime.now());
    } else if (alarms.selectedDays.length == 7) {
      return "everyday";
    } else {
      return alarms.selectedDays.map((dayMap) => dayMap.keys.first).join(', ');
    }
  }

  Future<void> showTime(BuildContext context) async {
    final currentTime = state.selectedTime ?? DateTime.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentTime.hour, minute: currentTime.minute),
    );
    if (picked != null) {
      state = state.copyWith(selectedTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, picked.hour, picked.minute));
    }
  }

  void deleteAlarm(int index) async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);
    final alarms = alarmPageNotifier.state.alarms ?? [];

    if (index < alarms.length) {
      final alarm = alarms[index];

      await AndroidAlarmManager.cancel(alarm.id!);
      await flutterLocalNotificationsPlugin.cancel(alarm.id!);

      final updatedAlarms = List<AlarmModel>.from(alarms);
      updatedAlarms.removeAt(index);

      alarmPageNotifier.state = alarmPageNotifier.state.copyWith(alarms: updatedAlarms);
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
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      dateTime: state.selectedTime ?? DateTime.now(),
      selectedDays: finalSelectedDays,
      title: teController.text.trim().isEmpty ? 'Alarm' : teController.text.trim(),
      isEnable: true,
      isVibrate: state.isVibrate ?? true,
    );

    teController.clear();
    final updatedList = List<AlarmModel>.from(alarmPageNotifier.state.alarms ?? []);

    updatedList.add(alarmModel);
    alarmPageNotifier.state = alarmPageNotifier.state.copyWith(alarms: updatedList);

    await AuthUtility().saveAlarm(updatedList);
    await setAlarm(alarmModel);

    resetData();
  }

  void updateAlarm() async {
    final alarmPageNotifier = ref.read(alarmPageProvider.notifier);
    final alarms = alarmPageNotifier.state.alarms ?? [];

    final index = alarms.indexWhere((alarm) => alarm.id == state.editingAlarmId);

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
        title: teController.text.trim().isEmpty ? 'Alarm' : teController.text.trim(),
        isEnable: state.isEnable ?? true,
        isVibrate: state.isVibrate ?? true,
      );

      await AndroidAlarmManager.cancel(updatedAlarm.id!);
      await flutterLocalNotificationsPlugin.cancel(updatedAlarm.id!);

      final updatedList = List<AlarmModel>.from(alarms);
      updatedList[index] = updatedAlarm;

      alarmPageNotifier.state = alarmPageNotifier.state.copyWith(alarms: updatedList);

      await AuthUtility().saveAlarm(updatedList);

      if (updatedAlarm.isEnable == true) {
        await setAlarm(updatedAlarm);
      }
    }

    resetData();
  }

  void editAlarm(BuildContext context, AlarmModel alarm) async {
    teController.text = alarm.title!;

    state = state.copyWith(
      isEnable: alarm.isEnable,
      selectedDays: alarm.selectedDays.map((e) => Map<String, dynamic>.from(e)).toList(),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SetAlarmBottomSheetContent(),
        );
      },
    );
  }

  Future<void> setAlarm(AlarmModel alarm) async {
    final now = DateTime.now();
    final currentTime = state.selectedTime ?? DateTime.now();

    DateTime alarmTime = DateTime(now.year, now.month, now.day, currentTime.hour, currentTime.minute);

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(Duration(days: 1));
    }
    final selectedDays = alarm.selectedDays;

    List<String> dayNames = selectedDays.map((dayMap) => dayMap.keys.first.toString()).toList();
    DateTime nextAlarmDateTime = calculateAlarmDateTime(dayNames, alarm.dateTime.hour, alarm.dateTime.minute);

    AndroidAlarmManager.oneShotAt(
      nextAlarmDateTime,
      alarm.id!,
      alarmClock: true,
      alarmCallback,
      exact: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
      wakeup: true,
    );
  }

  DateTime getNextAlarmDateTime(AlarmModel alarm) {
    final now = DateTime.now();
    final alarmTime = alarm.dateTime;
    final selectedDays = alarm.selectedDays;

    DateTime todayAlarm = DateTime(now.year, now.month, now.day, alarmTime.hour, alarmTime.minute);

    if (selectedDays.isEmpty) {
      if (now.isBefore(todayAlarm)) {
        return todayAlarm;
      } else {
        return todayAlarm.add(Duration(days: 1));
      }
    }

    List<String> dayNames = selectedDays.map((dayMap) => dayMap.keys.first.toString()).toList();

    return calculateAlarmDateTime(dayNames, alarmTime.hour, alarmTime.minute);
  }

  DateTime calculateAlarmDateTime(List<String> selectedDays, int hour, int minute) {
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
    List<int> selectedWeekdays = selectedDays.map((day) => weekdayMap[day]!).toList();

    int currentWeekday = now.weekday;
    bool isCurrentDaySelected = selectedWeekdays.contains(currentWeekday);

    DateTime todayAlarm = DateTime(now.year, now.month, now.day, hour, minute);

    if (isCurrentDaySelected && now.isBefore(todayAlarm)) {
      return todayAlarm;
    }

    return findNextAlarmDate(selectedWeekdays, currentWeekday, hour, minute, now);
  }

  DateTime findNextAlarmDate(List<int> selectedWeekdays, int currentWeekday, int hour, int minute, DateTime now) {
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

    DateTime nextAlarmDate = DateTime(now.year, now.month, now.day + daysToAdd, hour, minute);

    return nextAlarmDate;
  }
}

final setAlarmProvider = StateNotifierProvider<SetAlarmNotifier, SetAlarmState>((ref) => SetAlarmNotifier(ref));

Future<void> notificationsInitialize() async {
  const androidSetting = AndroidInitializationSettings("@mipmap/ic_launcher");
  const InitializationSettings initializationSettings = InitializationSettings(android: androidSetting);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) async {
      if (response.actionId == 'ACTION_ACCEPT') {
        log("Stop Button Pressed");
        await stopAlarm();
      } else if (response.payload == 'alarm_screen') {
        log("Navigating to Alarm Ring Screen");
        //await platform.invokeMethod('launchAlarmActivity', {'route': '/alarmRingScreen'});

        await scheduleAlarm("/alarmRingScreen");
      }
    },
  );
}

Future<void> stopAlarm() async {
  final container = ProviderContainer();
  container.read(setAlarmProvider.notifier).setAlarm(alarm);

  final sendPort = IsolateNameServer.lookupPortByName(_stopPortName);
  if (sendPort != null) {
    sendPort.send('STOP_ALARM');
    await alarmAudioPlayer.stop();
    IsolateNameServer.removePortNameMapping(_stopPortName);
    await Future.delayed(Duration(milliseconds: 500));
  }
}

Future<void> scheduleAlarm(String route) async {
  await platform.invokeMethod('scheduleAlarm', {'route': route});
}
