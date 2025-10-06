class AlarmModel {
  String? title;
  DateTime dateTime;
  List selectedDays;
  String? ringToneName;
  bool? isVibrate;
  bool? isEnable;

  AlarmModel({
    this.title,
    required this.dateTime,
    required this.selectedDays,
    this.ringToneName,
    this.isVibrate,
    this.isEnable
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "dateTime": dateTime,
      "selectedDays": selectedDays,
      "ringToneName": ringToneName,
      "isVibrate": isVibrate,
      "isEnable":isEnable
    };
  }
}
