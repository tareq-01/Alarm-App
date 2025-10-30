import 'package:alarm_app/views/alarm/screens/alarm_page.dart';
import 'package:alarm_app/services/app_route_const.dart';
import 'package:alarm_app/views/alarm/screens/alarm_ring_screen.dart';
import 'package:alarm_app/views/intro/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      name: AppRouteConst.splashScreen,
      path: "/",
      pageBuilder: (context, state) {
        return MaterialPage(child: SplashScreen());
      },
    ),
    GoRoute(
      name: AppRouteConst.homeRouteName,
      path: "/home",
      pageBuilder: (context, state) {
        return MaterialPage(child: AlarmPage());
      },
    ),
    GoRoute(
      name: AppRouteConst.alarmRingScreen,
      path: "/alarmRingScreen",
      pageBuilder: (context, state) {
        return MaterialPage(child: AlarmRingingScreen());
      },
    ),
  ],
);
