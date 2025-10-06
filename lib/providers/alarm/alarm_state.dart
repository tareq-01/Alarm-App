import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';

class AlarmState {

  bool? isVibrate;
  List<AlarmModel>? alarms;


  AlarmState({this.isVibrate,this.alarms=const[]});

  AlarmState copyWith({bool? isEnable, bool? isVibrate, List<AlarmModel>?alarms}) {
    return AlarmState(

      isVibrate: isEnable ?? this.isVibrate,
      alarms: alarms??this.alarms,
    );
  }
}
