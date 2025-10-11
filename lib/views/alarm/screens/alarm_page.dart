import 'package:alarm_app/providers/alarm/alarm_page_notifier.dart';
import 'package:alarm_app/providers/set_alarm.dart/set_alarm_notifier.dart';
import 'package:alarm_app/views/alarm/widgets/alarm_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// ignore: must_be_immutable
class AlarmPage extends ConsumerWidget {
  AlarmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmPageController = ref.read(alarmPageProvider.notifier);
    final alarmPageState = ref.watch(alarmPageProvider);
    var setAlarmNotifier = ref.read(setAlarmProvider.notifier);

    return SafeArea(
      top: false,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          SystemNavigator.pop();
        },

        child: Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromRGBO(235, 105, 163, 1),

            onPressed: () async {
              setAlarmNotifier.resetData();
              setAlarmNotifier.showDialog(context);
            },
            child: Icon(Icons.add, color: Colors.white),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: Text("Alarm App"),
            leading: SizedBox(),
          ),
          body: Stack(
            children: [
              alarmPageState.alarms!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alarm, size: 70),
                          Text(
                            "No Alarm",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SlidableAutoCloseBehavior(
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 80),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: alarmPageState.alarms!.length,
                                itemBuilder: (context, index) {
                                  var item = alarmPageState.alarms![index];

                                  return Slidable(
                                    key: ValueKey(item.id),
                                    closeOnScroll: false,
                                    endActionPane: ActionPane(
                                      dragDismissible: false,
                                      dismissible: DismissiblePane(
                                        onDismissed: () {},
                                      ),
                                      motion: ScrollMotion(),
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setAlarmNotifier.deleteAlarm(index);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.red,
                                            ),
                                            alignment: Alignment.center,
                                            height: 150,
                                            width: 130,
                                            child: Icon(
                                              Icons.delete,
                                              size: 38,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      child: AlarmListItem(
                                        title: item.title,
                                        isEnable: item.isEnable ?? false,
                                        alarmTime: item.dateTime,
                                        weekDays: alarmPageController.days(
                                          index,
                                        ),
                                        remainingTime: "8hr 10min",
                                        onActive: (bool value) {
                                          alarmPageController.toggleSwitch(
                                            index,
                                          );
                                        },

                                        onTap: () {
                                          setAlarmNotifier.editAlarm(
                                            context,
                                            alarmPageState.alarms![index],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              Positioned(
                bottom: 0,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,

                      colors: [Colors.black, Colors.transparent],
                      stops: [0.0, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
