import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AlarmListItem extends StatelessWidget {
  const AlarmListItem({
    super.key,
    this.title,
    this.isEnable,
    this.weekDays,
    this.remainingTime,
    this.onActive,
    this.onTap,
    this.alarmTime,
  });
  final String? title;
  final bool? isEnable;
  final String? weekDays;
  final String? remainingTime;
  final Function(bool)? onActive;
  final Function()? onTap;
  final DateTime? alarmTime;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: isEnable! ? Colors.grey : Color(0xFFd4712a),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toString(),
                    style: TextStyle(
                      color: isEnable! ? Colors.black : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Switch(value: isEnable!, onChanged: onActive),
                ],
              ),
              Consumer(
                builder: (context, ref, widget) {
                  final alarmListController = ref.read(
                    alarmPageProvider.notifier,
                  );
                  return InkWell(
                    onTap: () async {
                      alarmListController.showTime(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: DateFormat(
                              "hh",
                            ).format(alarmTime ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 40,
                              color: isEnable == true
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: ":",
                            style: TextStyle(
                              fontSize: 40,

                              color: isEnable == true
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),

                          TextSpan(
                            text: DateFormat(
                              "mm",
                            ).format(alarmTime ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 40,
                              color: isEnable == true
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          WidgetSpan(child: SizedBox(width: 6)),
                          TextSpan(
                            text: DateFormat(
                              "a",
                            ).format(alarmTime ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 20,
                              color: isEnable == true
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          // TextSpan(
                          //   text: alarmTime?.toString(),
                          //   style: TextStyle(
                          //     fontSize: 40,
                          //     color: isEnable == true ? Colors.black : Colors.white,
                          //   ),
                          // ),
                          // TextSpan(
                          //   text:
                          //       // timeOfDay.period == DayPeriod.am
                          //       // ? "AM"
                          //       // : "PM",
                          //       alarmTime.toString(),
                          //   style: TextStyle(
                          //     fontSize: 20,
                          //     color: isEnable == true ? Colors.black : Colors.white,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    weekDays.toString(),
                    style: TextStyle(
                      color: isEnable == true ? Colors.black : Colors.white,
                    ),
                  ),

                  Text(
                    remainingTime.toString(),
                    style: TextStyle(
                      color: isEnable == true ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
