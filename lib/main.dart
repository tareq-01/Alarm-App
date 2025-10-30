import 'dart:developer';

import 'package:alarm_app/providers/set_alarm.dart/set_alarm_notifier.dart';
import 'package:alarm_app/services/app_route.dart';
import 'package:alarm_app/views/alarm/screens/alarm_ring_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await notificationsInitialize();
  runApp(ProviderScope(child: MyApp()));
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      
      key: navigatorKey,
      title: 'Simple Alarm App',
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity, textTheme: TextTheme()),
      debugShowCheckedModeBanner: false,

      routerConfig: router,
    );
  }
}
