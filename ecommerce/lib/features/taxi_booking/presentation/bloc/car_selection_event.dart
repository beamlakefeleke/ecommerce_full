import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';

sealed class CarSelectionEvent extends Equatable {
  const CarSelectionEvent();

  @override
  List<Object?> get props => [];
}

class ToggleCarFilterEvent extends CarSelectionEvent {}

class SetBrandModelEvent extends CarSelectionEvent {
  final int index;

  const SetBrandModelEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class SetSortByEvent extends CarSelectionEvent {
  final int index;

  const SetSortByEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class SelectPriceRangeEvent extends CarSelectionEvent {
  final RangeValues newRange;

  const SelectPriceRangeEvent({required this.newRange});

  @override
  List<Object?> get props => [newRange];
}

class GetVehiclesListEvent extends CarSelectionEvent {
  final UserInformationBody body;
  final int offset;
  final bool isUpdate;

  const GetVehiclesListEvent({
    required this.body,
    required this.offset,
    this.isUpdate = false,
  });

  @override
  List<Object?> get props => [body, offset, isUpdate];
}

class GetBrandListEvent extends CarSelectionEvent {}
