class SetAlarmState {
  bool? isEnable;
  bool? isVibrate;
  DateTime? selectedTime;
  int? selectedDay;
  String? title;
  List<Map<String, dynamic>>? selectedDays;
  SetAlarmState({
    this.isEnable = false,
    this.isVibrate,
    this.selectedTime,
    this.selectedDay = 0,
    this.title,
    this.selectedDays = const [],
  });

  SetAlarmState copyWith({
    bool? isEnable,
    bool? isVibrate,
    DateTime? selectedTime,
    int? selectedDay,
    String? title,

    List<Map<String, dynamic>>? selectedDays,
  }) {
    return SetAlarmState(
      isEnable: isEnable ?? this.isEnable,

      isVibrate: isVibrate ?? this.isVibrate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedDays: selectedDays ?? this.selectedDays,
      title: title ?? this.title,
    );
  }
}
