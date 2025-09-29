class SetAlarmState {
  bool? isEnable;
  bool? isVibrate;
  DateTime? selectedTime;

  SetAlarmState({this.isEnable = false, this.isVibrate,this.selectedTime});

  SetAlarmState copyWith({bool? isEnable, bool? isVibrate,  DateTime? selectedTime
}) {
    return SetAlarmState(
      isEnable: isEnable ?? this.isEnable,

      isVibrate: isVibrate ?? this.isVibrate,
      selectedTime: selectedTime??this.selectedTime
    );
  }
}
