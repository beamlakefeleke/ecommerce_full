import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';

/// Pure result of a zone lookup. Mirrors the legacy [ZoneResponseModel] but as
/// an immutable value object the bloc/helper can carry across layers.
class ZoneResult extends Equatable {
  final bool isSuccess;
  final String? message;
  final List<int> zoneIds;
  final List<ZoneData> zoneData;
  final List<int> areaIds;

  const ZoneResult({
    required this.isSuccess,
    required this.message,
    required this.zoneIds,
    required this.zoneData,
    required this.areaIds,
  });

  @override
  List<Object?> get props => [isSuccess, message, zoneIds, zoneData, areaIds];
}
