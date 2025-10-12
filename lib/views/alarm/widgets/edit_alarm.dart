import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:alarm_app/providers/set_alarm.dart/set_alarm_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditAlarmButton extends ConsumerWidget {
  const EditAlarmButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var setAlarmNotifier = ref.read(setAlarmProvider.notifier);
    var setAlarmState = ref.watch(setAlarmProvider);
    return Padding(
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
                    onTap: () async {},
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: DateFormat("hh").format(
                              setAlarmState.selectedTime ?? DateTime.now(),
                            ),
                            style: TextStyle(fontSize: 40, color: Colors.black),
                          ),
                          TextSpan(
                            text: ":",
                            style: TextStyle(fontSize: 40, color: Colors.black),
                          ),

                          TextSpan(
                            text: DateFormat("mm").format(
                              setAlarmState.selectedTime ?? DateTime.now(),
                            ),
                            style: TextStyle(fontSize: 40, color: Colors.black),
                          ),
                          WidgetSpan(child: SizedBox(width: 6)),
                          TextSpan(
                            text: DateFormat("a").format(
                              setAlarmState.selectedTime ?? DateTime.now(),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
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
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      alignment: Alignment.center,
                      height: 38,
                      width: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:
                            (setAlarmState.selectedDays ?? []).any(
                              (e) => setAlarmNotifier.weekdays[index]
                                  .containsKey(e.keys.first),
                            )
                            ? Color.fromRGBO(235, 65, 127, 1)
                            : Colors.grey,
                      ),
                      child: Text(
                        setAlarmNotifier.day(index),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

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
                  onChanged: ((value) {
                    setAlarmNotifier.toggleVibrate();
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
                  backgroundColor: Color.fromRGBO(235, 65, 127, 1),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                ),
                onPressed: () async {
                  //setAlarmNotifier.editAlarm(context);
                  setAlarmNotifier.updateAlarm();

                  setAlarmNotifier.teController;
                  Navigator.pop(context);
                },
                child: Text(
                  "Update",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
