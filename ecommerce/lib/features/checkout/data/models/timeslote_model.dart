import 'package:ecommerce/features/checkout/domain/entities/time_slot.dart';

class TimeSlotModel {
  int? day;
  DateTime? startTime;
  DateTime? endTime;

  TimeSlotModel({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  TimeSlot toEntity() =>
      TimeSlot(day: day, startTime: startTime, endTime: endTime);

  factory TimeSlotModel.fromEntity(TimeSlot e) =>
      TimeSlotModel(day: e.day, startTime: e.startTime, endTime: e.endTime);

  TimeSlotModel.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}
