import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';

sealed class CarSelectionEvent extends Equatable {
  const CarSelectionEvent();

  @override
  List<Object?> get props => [];
}

/// Load a page of vehicles for the given trip filter body. `offset` 1 is the
/// first page / refresh / apply-filter.
class VehiclesRequested extends CarSelectionEvent {
  final UserInformationBody body;
  final int offset;

  const VehiclesRequested({required this.body, this.offset = 1});

  @override
  List<Object?> get props => [identityHashCode(body), offset];
}

/// Load the vehicle brand list for the filter panel.
class BrandListRequested extends CarSelectionEvent {
  const BrandListRequested();
}

/// Toggle the expandable filter panel open/closed.
class CarFilterToggled extends CarSelectionEvent {
  const CarFilterToggled();
}

class BrandSelected extends CarSelectionEvent {
  final int index;
  const BrandSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class SortBySelected extends CarSelectionEvent {
  final int index;
  const SortBySelected(this.index);

  @override
  List<Object?> get props => [index];
}

/// Move the price range slider. Derives startingPrice / endingPrice (×1000),
/// mirroring the legacy controller.
class PriceRangeSelected extends CarSelectionEvent {
  final RangeValues range;
  const PriceRangeSelected(this.range);

  @override
  List<Object?> get props => [range];
}
