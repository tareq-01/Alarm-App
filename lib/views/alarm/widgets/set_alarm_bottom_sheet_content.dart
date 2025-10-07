import 'package:alarm_app/providers/set_alarm.dart/set_alarm_notifier.dart';
import 'package:alarm_app/services/constants/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SetAlarmBottomSheetContent extends ConsumerWidget {
  const SetAlarmBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var setAlarmNotifier = ref.read(setAlarmProvider.notifier);
    var setAlarmState = ref.watch(setAlarmProvider);
    return SizedBox(
      width: double.infinity,
      height: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        //await alarmPageController.showTime(context);
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: DateFormat("hh").format(
                                setAlarmState.selectedTime ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ":",
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                              ),
                            ),

                            TextSpan(
                              text: DateFormat("mm").format(
                                setAlarmState.selectedTime ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                              ),
                            ),
                            WidgetSpan(child: SizedBox(width: 6)),
                            TextSpan(
                              text: DateFormat("a").format(
                                setAlarmState.selectedTime ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await setAlarmNotifier.showTime(context);
                      },
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  7,
                  (index) => InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setAlarmNotifier.selectedDay(
                        setAlarmNotifier.weekdays[index],
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:
                              (setAlarmState.selectedDays ?? []).any(
                                (e) => setAlarmNotifier.weekdays[index]
                                    .containsKey(e.keys.first),
                              )
                              ? Color(0xFFd4712a)
                              : Colors.grey,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: Text(
                            setAlarmNotifier.day(index),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text("Upcoming Alarm"),
              //         Text("Fri,Sep 27"),
              //       ],
              //     ),
              //     InkWell(
              //       onTap: showDate,
              //       child: Wrap(
              //         children: [
              //           Icon(Icons.calendar_month),
              //           SizedBox(width: 5),
              //           Text("Schedule Alarm"),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    "Rington",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text("Ringtone Name"),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Vibrate",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Switch(
                    value: setAlarmState.isVibrate ?? false,
                    onChanged: ((value6) {
                      setAlarmState.isVibrate = value6;
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Title",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  SizedBox(
                    width: 120,
                    height: 40,
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      //textAlignVertical: TextAlignVertical.center,

                      controller: setAlarmNotifier.teController,
                      decoration: InputDecoration(
                        filled: true,
                            isDense: true,

                        fillColor: Colors.white,
                        hintText: "Alarm Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 100),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFd4712a),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                    ),
                  ),
                  onPressed: () async{
                    setAlarmNotifier.saveAlarm(
                      setAlarmNotifier.teController.toString(),

                    );
                    setAlarmNotifier.teController;
                    Navigator.pop(context);
                  },
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
