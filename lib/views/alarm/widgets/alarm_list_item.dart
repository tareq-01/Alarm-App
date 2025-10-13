import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AlarmListItem extends ConsumerWidget {
  const AlarmListItem({
    super.key,
    this.title,
    this.isEnable = false,
    this.weekDays,
    this.remainingTime,
    this.onActive,
    this.onTap,
    this.alarmTime,
  });
  final String? title;
  final bool isEnable;
  final String? weekDays;
  final String? remainingTime;
  final Function(bool)? onActive;
  final Function()? onTap;
  final DateTime? alarmTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Card(
        color: isEnable
            ? Color.fromRGBO(235, 65, 127, 1)
            : Color.fromRGBO(238, 143, 178, 1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toString(),
                    style: TextStyle(
                      color: isEnable ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    width: 50,
                    child: Switch(
                      padding: EdgeInsets.zero,
                      value: isEnable,
                      onChanged: onActive,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // This is the key
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Consumer(
                builder: (context, ref, widget) {
                  final alarmListController = ref.read(
                    alarmPageProvider.notifier,
                  );
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: DateFormat(
                            "hh",
                          ).format(alarmTime ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 40,
                            color: isEnable == true
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ":",
                          style: TextStyle(
                            fontSize: 40,
                  
                            color: isEnable == true
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                  
                        TextSpan(
                          text: DateFormat(
                            "mm",
                          ).format(alarmTime ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 40,
                            color: isEnable == true
                                ? Colors.white
                                : Colors.black,
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
                                ? Colors.white
                                : Colors.black,
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
                  );
                },
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    weekDays.toString(),
                    style: TextStyle(
                      color: isEnable == true ? Colors.white : Colors.black,
                    ),
                  ),

                  Text(
                    remainingTime.toString(),
                    style: TextStyle(
                      color: isEnable == true ? Colors.white : Colors.black,
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
