import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/brand_model.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/vehicle_model.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_event.dart';
import 'package:ecommerce/core/di/injection.dart';

class CarSelectionController extends GetxController implements GetxService {
  late final CarSelectionBloc carSelectionBloc;
  
  CarSelectionController() {
    carSelectionBloc = getIt<CarSelectionBloc>();
    carSelectionBloc.stream.listen((state) {
      update();
    });
  }

  bool get isCarFilterActive => carSelectionBloc.state.isCarFilterActive;
  VehicleModel? get vehicleModel => carSelectionBloc.state.vehicleModel;
  RangeValues get selectedPriceRange => carSelectionBloc.state.selectedPriceRange;
  double get startingPrice => carSelectionBloc.state.startingPrice;
  double get endingPrice => carSelectionBloc.state.endingPrice;
  List<BrandModel>? get brandModels => carSelectionBloc.state.brandModels;
  int get selectedBrand => carSelectionBloc.state.selectedBrand;
  int get sortByIndex => carSelectionBloc.state.sortByIndex;

  void carFilter(){
    carSelectionBloc.add(ToggleCarFilterEvent());
  }

  void setBrandModel(int index){
    carSelectionBloc.add(SetBrandModelEvent(index: index));
  }

  void setSortBy(int index){
    carSelectionBloc.add(SetSortByEvent(index: index));
  }

  void selectPriceRange(RangeValues newRange){
    carSelectionBloc.add(SelectPriceRangeEvent(newRange: newRange));
  }

  Future<void> getVehiclesList(UserInformationBody body, int offset, {bool isUpdate = false}) async{
    carSelectionBloc.add(GetVehiclesListEvent(body: body, offset: offset, isUpdate: isUpdate));
  }

  Future<void> getBrandList() async {
    carSelectionBloc.add(GetBrandListEvent());
  }
}