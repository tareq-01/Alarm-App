import 'package:flutter/material.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,

          onPressed: () {},
          child: Icon(Icons.add, color: Colors.white),
        ),
        appBar: AppBar(centerTitle: true, title: Text("Alarms")),
      ),
    );
  }
}
