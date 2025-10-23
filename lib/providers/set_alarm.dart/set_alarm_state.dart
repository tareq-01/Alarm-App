class SetAlarmState {
  bool? isEnable;
  bool? isVibrate;
  DateTime? selectedTime;
  int? selectedDay;
  String? title;
  List<Map<String, dynamic>>? selectedDays;
  int? editingAlarmId;
  int? alarmRingId;

  SetAlarmState({
    this.isEnable = true,
    this.isVibrate,
    this.selectedTime,
    this.selectedDay = 0,
    this.title,
    this.editingAlarmId,
    this.alarmRingId,
    this.selectedDays = const [],
  });

  SetAlarmState copyWith({
    bool? isEnable = true,
    bool? isVibrate,
    DateTime? selectedTime,
    int? selectedDay,
    String? title,
    int? editingAlarmId,
      int? alarmRingId,


    List<Map<String, dynamic>>? selectedDays,  
  }) {
    return SetAlarmState(
      isEnable: isEnable ?? this.isEnable,
      isVibrate: isVibrate ?? this.isVibrate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedDays: selectedDays ?? this.selectedDays,
      title: title ?? this.title,
      editingAlarmId: editingAlarmId ?? this.editingAlarmId,
      alarmRingId: alarmRingId??this.alarmRingId,
    );
  }
}
