import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';

/// Load status for the top-rated vehicles list.
enum TopRatedVehiclesStatus { initial, loading, loaded, error }

/// Single immutable state for the migrated taxi-booking slice.
///
/// Currently covers only the top-rated vehicles list (first slice). Later
/// slices add their fields here and extend [props].
class TaxiState extends Equatable {
  final TopRatedVehiclesStatus topRatedStatus;
  final VehicleModel? topRatedVehicles;
  final String? errorMessage;

  const TaxiState({
    this.topRatedStatus = TopRatedVehiclesStatus.initial,
    this.topRatedVehicles,
    this.errorMessage,
  });

  TaxiState copyWith({
    TopRatedVehiclesStatus? topRatedStatus,
    VehicleModel? topRatedVehicles,
    bool clearTopRatedVehicles = false,
    String? errorMessage,
  }) {
    return TaxiState(
      topRatedStatus: topRatedStatus ?? this.topRatedStatus,
      topRatedVehicles: clearTopRatedVehicles
          ? null
          : (topRatedVehicles ?? this.topRatedVehicles),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [topRatedStatus, topRatedVehicles, errorMessage];
}
