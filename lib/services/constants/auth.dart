import 'dart:convert';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUtility {
  static const String key = "selected_days";


   Future<void> saveAlarm(List<AlarmModel> alarm) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> objectStrings = alarm
        .map((element) => jsonEncode(element.toJson()))
        .toList();

    await pref.setStringList(key, objectStrings);
  }



   Future<List<AlarmModel>> getAlarm() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    List<String>? objectStrings = pref.getStringList(key);
    if (objectStrings == null) {
      return [];
    }

    return objectStrings
        .map((element) => AlarmModel.fromJson(jsonDecode(element)))
        .toList();
  }

   Future<void> clearAlarm() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }
}
