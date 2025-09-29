class AlarmState {
  bool? isEnable;
  bool? isVibrate;

  AlarmState({this.isEnable = false, this.isVibrate});

  AlarmState copyWith({bool? isEnable, bool? isVibrate}) {
    return AlarmState(
      isEnable: isEnable ?? this.isEnable,

      isVibrate: isEnable ?? this.isVibrate,
    );
  }
}
