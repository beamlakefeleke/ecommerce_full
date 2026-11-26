import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_state.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/paginated_list_view.dart';
import 'package:ecommerce/features/taxi_booking/widgets/trip_info_widget.dart';
import 'widgets/car_filter_widget.dart';
import 'widgets/rider_car_list.dart';

class SelectCarScreen extends StatelessWidget {
  final UserInformationBody filterBody;
  const SelectCarScreen({super.key, required this.filterBody});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CarSelectionBloc>(
      create: (_) => getIt<CarSelectionBloc>()
        ..add(const BrandListRequested())
        ..add(VehiclesRequested(body: filterBody)),
      child: _SelectCarView(filterBody: filterBody),
    );
  }
}

class _SelectCarView extends StatefulWidget {
  final UserInformationBody filterBody;
  const _SelectCarView({required this.filterBody});

  @override
  State<_SelectCarView> createState() => _SelectCarViewState();
}

class _SelectCarViewState extends State<_SelectCarView> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? null
          : CustomAppBar(title: 'select_car'.tr),
      body: BlocBuilder<CarSelectionBloc, CarSelectionState>(
        builder: (context, state) {
          return ExpandableBottomSheet(
            background: GestureDetector(
              onTap: () {
                if (state.isCarFilterActive) {
                  context.read<CarSelectionBloc>().add(
                    const CarFilterToggled(),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    color: Theme.of(context).canvasColor,
                    margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TripInfoWidget(filterBody: widget.filterBody),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'car_list'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.read<CarSelectionBloc>().add(
                                const CarFilterToggled(),
                              ),
                              child: Container(
                                width: 27,
                                height: 21,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                child: Image.asset(
                                  Images.carFilter,
                                  scale: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],
                    ),
                  ),

                  Expanded(
                    child: state.vehicleModel != null
                        ? state.vehicleModel!.vehicles!.isNotEmpty
                              ? RefreshIndicator(
                                  onRefresh: () async =>
                                      context.read<CarSelectionBloc>().add(
                                        VehiclesRequested(
                                          body: widget.filterBody,
                                        ),
                                      ),
                                  child: Container(
                                    width: Dimensions.webMaxWidth,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                    ),
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: PaginatedListView(
                                        offset: state.vehicleModel!.offset,
                                        onPaginate: (int? offset) async =>
                                            context
                                                .read<CarSelectionBloc>()
                                                .add(
                                                  VehiclesRequested(
                                                    body: widget.filterBody,
                                                    offset: offset!,
                                                  ),
                                                ),
                                        scrollController: scrollController,
                                        totalSize:
                                            state.vehicleModel!.totalSize,
                                        itemView: RiderCarList(
                                          vehicleModel: state.vehicleModel,
                                          filterBody: widget.filterBody,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(child: Text('no_vehicle_available'.tr))
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
            persistentContentHeight: 500,
            expandableContent: const CarFilterWidget(),
            persistentFooter: state.isCarFilterActive
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: kElevationToShadow[4],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeSmall,
                        ),
                        child: CustomButton(
                          buttonText: 'apply_filter'.tr,
                          onPressed: () {
                            final UserInformationBody filterBody =
                                UserInformationBody(
                                  from: widget.filterBody.from,
                                  to: widget.filterBody.to,
                                  fareCategory: widget.filterBody.fareCategory,
                                  distance: widget.filterBody.distance,
                                  minPrice: state.startingPrice,
                                  maxPrice: state.endingPrice,
                                  brandModelId:
                                      state.brandModels[state.selectedBrand].id,
                                  filterType: state.sortByIndex == 0
                                      ? 'top_rated'
                                      : 'km/h',
                                );
                            final bloc = context.read<CarSelectionBloc>();
                            bloc.add(const CarFilterToggled());
                            bloc.add(VehiclesRequested(body: filterBody));
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          );
        },
      ),
    );
  }
}
