import 'package:flutter/material.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  bool isVibrate = false;
  bool isEnable = false;
  int Selectedindex = -1;
  @override
  Widget build(BuildContext context) {
    TimeOfDay timeOfDay = TimeOfDay.now();
    DateTime selectedDate = DateTime.now();
    void selected(bool value) {
      setState(() {
        isEnable = !isEnable;
      });
    }

    Future<void> showTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: timeOfDay,
      );
      setState(() {
        timeOfDay = picked!;
      });
    }

    void showDate() {
      showDatePicker(
        context: context,
        firstDate: selectedDate,
        lastDate: selectedDate,
        initialDate: selectedDate,
      );
    }

    List<String> data = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"];
    void showDialouge() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
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
                            onTap: showTime,
                            child: Text(
                              timeOfDay.format(context).toString(),
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                          InkWell(onTap: showTime, child: Text("Edit")),
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
                            setState(() {
                              Selectedindex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 7),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Selectedindex == index
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(11),
                                child: Text(data[index]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Upcoming Alarm"),
                            Text("Fri,Sep 27"),
                          ],
                        ),
                        InkWell(
                          onTap: showDate,
                          child: Wrap(
                            children: [
                              Icon(Icons.calendar_month),
                              SizedBox(width: 5),
                              Text("Schedule Alarm"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [Text("Rington"), Text("Ringtone Name")],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Vibrate"),
                        Switch(
                          value: isVibrate,
                          onChanged: ((value6) {
                            setState(() {
                              isVibrate = value6;
                            });
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 150),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: Text("Delete"),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,

          onPressed: showTime,
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
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: showDialouge,
                      child: Card(
                        color: isEnable == true ? Colors.grey : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sat Sun Mon Tue"),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: showTime,
                                    child: Text(
                                      timeOfDay.format(context),
                                      style: TextStyle(fontSize: 30),
                                    ),
                                  ),

                                  Switch(value: isEnable, onChanged: selected),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
