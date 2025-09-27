import 'package:alarm_app/services/app_route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp.router(
      title: 'Simple Alarm App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      // routeInformationParser: MyAppRouter().router.routeInformationParser,
      // routerDelegate: MyAppRouter().router.routerDelegate,
      routerConfig: router,
    );
  }
}
