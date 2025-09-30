class SetAlarmState {
  bool? isEnable;
  bool? isVibrate;
  DateTime? selectedTime;
  int? selectedDay;
  List<int>? selectedDays = [];
  SetAlarmState({
    this.isEnable = false,
    this.isVibrate,
    this.selectedTime,
    this.selectedDay = 0,
    this.selectedDays,
  });

  SetAlarmState copyWith({
    bool? isEnable,
    bool? isVibrate,
    DateTime? selectedTime,
    int? selectedDay,
    List<int>? selectedDays,
  }) {
    return SetAlarmState(
      isEnable: isEnable ?? this.isEnable,

      isVibrate: isVibrate ?? this.isVibrate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}
