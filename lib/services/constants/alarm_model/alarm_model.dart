class AlarmModel {
  String? title;
  DateTime dateTime;
  List selectedDays;
  String?ringToneName;
  bool? isVibrate;
  
  AlarmModel({
     this.title,
    required this.dateTime,
    required this.selectedDays,
     this.ringToneName,
     this.isVibrate,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "dateTime": dateTime,
      "selectedDays": selectedDays,
      "ringToneName": ringToneName,
      "isVibrate": isVibrate,
    };
  }

}
