import 'package:alarm/alarm.dart';
import 'package:alarm_app/services/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,

        textTheme: TextTheme(),
      ),
      debugShowCheckedModeBanner: false,

      routerConfig: router,
    );
  }
}
