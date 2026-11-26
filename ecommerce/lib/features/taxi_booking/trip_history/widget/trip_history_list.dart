import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_state.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';
import 'package:ecommerce/common/widgets/paginated_list_view.dart';
import 'package:get/get.dart';
import '../../widgets/trip_history_item.dart';

class TripHistoryList extends StatelessWidget {
  final String type;
  const TripHistoryList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      body: BlocBuilder<RiderBloc, RiderState>(
        builder: (context, riderController) {
          return riderController.runningTrip != null
              ? riderController.runningTrip!.orders!.data!.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          context.read<RiderBloc>().add(
                            const RunningTripListRequested(),
                          );
                        },
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: FooterView(
                            child: SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: PaginatedListView(
                                scrollController: scrollController,
                                onPaginate: (int? offset) =>
                                    context.read<RiderBloc>().add(
                                      RunningTripListRequested(offset: offset!),
                                    ),
                                totalSize:
                                    riderController.runningTrip?.totalSize,
                                offset: riderController.runningTrip != null
                                    ? int.parse(
                                        riderController.runningTrip!.offset!,
                                      )
                                    : null,
                                itemView: ListView.builder(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  itemCount: riderController
                                      .runningTrip!
                                      .orders!
                                      .data!
                                      .length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return TripHistoryItem(
                                      trip: riderController
                                          .runningTrip!
                                          .orders!
                                          .data![index],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : NoDataScreen(text: 'no_trip_found'.tr, showFooter: true)
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
