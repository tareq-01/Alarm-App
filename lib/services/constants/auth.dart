import 'dart:convert';
import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUtility {
  static const String key = "selected_days";

  Future<void> saveAlarm(List<AlarmModel> alarm) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String objectStrings = jsonEncode(alarm.map((e) => e.toJson()).toList());
    await pref.setString(key, objectStrings);
  }


  Future<List<AlarmModel>> getAlarm() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    String? objectStrings = pref.getString(key);
    if (objectStrings == null) {
      return [];
    }
    List jsonList = jsonDecode(objectStrings);

    return jsonList.map((e) => AlarmModel.fromJson(e)).toList();
  }

  Future<void> clearAlarm() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }

}
