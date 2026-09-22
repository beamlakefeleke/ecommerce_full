import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/models/brand_model.dart';
import '../../domain/models/vehicle_model.dart';

sealed class CarSelectionState extends Equatable {
  final bool isCarFilterActive;
  final RangeValues selectedPriceRange;
  final double startingPrice;
  final double endingPrice;
  final VehicleModel? vehicleModel;
  final List<BrandModel>? brandModels;
  final int selectedBrand;
  final int sortByIndex;

  const CarSelectionState({
    required this.isCarFilterActive,
    required this.selectedPriceRange,
    required this.startingPrice,
    required this.endingPrice,
    this.vehicleModel,
    this.brandModels,
    required this.selectedBrand,
    required this.sortByIndex,
  });

  @override
  List<Object?> get props => [
    isCarFilterActive,
    selectedPriceRange,
    startingPrice,
    endingPrice,
    vehicleModel,
    brandModels,
    selectedBrand,
    sortByIndex,
  ];
}

class CarSelectionInitial extends CarSelectionState {
  const CarSelectionInitial({
    bool isCarFilterActive = false,
    RangeValues selectedPriceRange = const RangeValues(0.2, 2.0),
    double startingPrice = 0.0,
    double endingPrice = 2000.0,
    VehicleModel? vehicleModel,
    List<BrandModel>? brandModels,
    int selectedBrand = 0,
    int sortByIndex = 0,
  }) : super(
    isCarFilterActive: isCarFilterActive,
    selectedPriceRange: selectedPriceRange,
    startingPrice: startingPrice,
    endingPrice: endingPrice,
    vehicleModel: vehicleModel,
    brandModels: brandModels,
    selectedBrand: selectedBrand,
    sortByIndex: sortByIndex,
  );
}

class CarSelectionUpdated extends CarSelectionState {
  const CarSelectionUpdated({
    required bool isCarFilterActive,
    required RangeValues selectedPriceRange,
    required double startingPrice,
    required double endingPrice,
    VehicleModel? vehicleModel,
    List<BrandModel>? brandModels,
    required int selectedBrand,
    required int sortByIndex,
  }) : super(
    isCarFilterActive: isCarFilterActive,
    selectedPriceRange: selectedPriceRange,
    startingPrice: startingPrice,
    endingPrice: endingPrice,
    vehicleModel: vehicleModel,
    brandModels: brandModels,
    selectedBrand: selectedBrand,
    sortByIndex: sortByIndex,
  );
}

class CarSelectionError extends CarSelectionState {
  final String message;

  const CarSelectionError({
    required this.message,
    required bool isCarFilterActive,
    required RangeValues selectedPriceRange,
    required double startingPrice,
    required double endingPrice,
    VehicleModel? vehicleModel,
    List<BrandModel>? brandModels,
    required int selectedBrand,
    required int sortByIndex,
  }) : super(
    isCarFilterActive: isCarFilterActive,
    selectedPriceRange: selectedPriceRange,
    startingPrice: startingPrice,
    endingPrice: endingPrice,
    vehicleModel: vehicleModel,
    brandModels: brandModels,
    selectedBrand: selectedBrand,
    sortByIndex: sortByIndex,
  );

  @override
  List<Object?> get props => [...super.props, message];
}
