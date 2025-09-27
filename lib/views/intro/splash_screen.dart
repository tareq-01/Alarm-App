import 'dart:async';

import 'package:alarm_app/services/app_route.dart';
import 'package:alarm_app/services/app_route_const.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(
      Duration(seconds: 3),
      () =>
          //      GoRouter.of(context).pushNamed("/"),
          router.push("/home"),
      //GoRouter.of(context).go(AppRouteConst.homeRouteName),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/bell.png",
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
