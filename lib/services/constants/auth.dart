import 'package:shared_preferences/shared_preferences.dart';

class AuthUtility {
  static const String key = "selected_days";

  static Future<void> saveAlarm()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
   

  }
}
