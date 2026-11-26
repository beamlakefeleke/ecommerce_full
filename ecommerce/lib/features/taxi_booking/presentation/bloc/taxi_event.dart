import 'package:equatable/equatable.dart';

sealed class TaxiEvent extends Equatable {
  const TaxiEvent();

  @override
  List<Object?> get props => [];
}

/// Load the top-rated vehicles list. `offset` 1 is the first page / refresh.
class TopRatedVehiclesRequested extends TaxiEvent {
  final int offset;
  const TopRatedVehiclesRequested({this.offset = 1});

  @override
  List<Object?> get props => [offset];
}
