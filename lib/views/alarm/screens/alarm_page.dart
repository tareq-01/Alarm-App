import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:alarm_app/providers/set_alarm.dart/set_alarm_notifier.dart';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:alarm_app/views/alarm/widgets/alarm_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class AlarmPage extends ConsumerWidget {
  AlarmPage({super.key});

  bool isVibrate = false;

  int Selectedindex = -1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmPageController = ref.read(alarmPageProvider.notifier);
    final alarmPageState = ref.watch(alarmPageProvider);
    var setAlarmNotifier = ref.read(setAlarmProvider.notifier);
    DateTime selectedDate = DateTime.now();

    void showDate() {
      showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: DateTime.now(),
      );
    }

    //log("here");
    return SafeArea(
      top: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(112, 189, 130, 54),

          onPressed: () async {
            setAlarmNotifier.showDialouge(context);
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
        appBar: AppBar(centerTitle: true, title: Text("Alarm App")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: alarmPageState.alarms!.length,
                  itemBuilder: (context, index) {
                    var item = alarmPageState.alarms![index];

                    return AlarmListItem(
                      title: item.title??null,
                      //title:alarmPageController.alarms,
                      isEnable: item.isEnable ?? false,
                      alarmTime: item.dateTime,
                      weekDays: alarmPageController.days(index),
                      remainingTime: "8hr 10min",
                      onActive: (bool value) => alarmPageController.toggleSwitch(index),
                      onTap: () {},
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
