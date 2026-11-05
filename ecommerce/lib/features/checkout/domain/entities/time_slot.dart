import 'package:equatable/equatable.dart';

/// Pure domain entity representing a schedulable delivery/pickup time slot.
class TimeSlot extends Equatable {
  final int? day;
  final DateTime? startTime;
  final DateTime? endTime;

  const TimeSlot({this.day, this.startTime, this.endTime});

  @override
  List<Object?> get props => [day, startTime, endTime];
}
