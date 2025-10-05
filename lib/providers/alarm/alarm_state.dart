import 'package:alarm_app/services/constants/alarm_model/alarm_model.dart';

class AlarmState {
  bool? isEnable;
  bool? isVibrate;
  List<AlarmModel>? alarms;


  AlarmState({this.isEnable = false, this.isVibrate,this.alarms=const[]});

  AlarmState copyWith({bool? isEnable, bool? isVibrate, List<AlarmModel>?alarms}) {
    return AlarmState(
      isEnable: isEnable ?? this.isEnable,

      isVibrate: isEnable ?? this.isVibrate,
      alarms: alarms??this.alarms,
    );
  }
}
