import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/location/domain/repositories/location_repository.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_state.dart';
import 'package:ecommerce/features/location/domain/models/prediction_model.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';

/// Pickup/destination search field for the select-map screen.
///
/// Owns its own `TextEditingController` (a bloc must not hold a
/// `TextEditingController`); it seeds the text from the bloc's current
/// from/to address and syncs it when that address changes. Autocomplete
/// predictions are a read-only query served directly by the migrated
/// [LocationRepository]; selecting one dispatches a bloc event.
class RiderAddressInputField extends StatefulWidget {
  final bool isFormAddress;
  const RiderAddressInputField({super.key, required this.isFormAddress});

  @override
  State<RiderAddressInputField> createState() => _RiderAddressInputFieldState();
}

class _RiderAddressInputFieldState extends State<RiderAddressInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<RiderBloc>().state;
    final address = widget.isFormAddress ? state.fromAddress : state.toAddress;
    _controller.text = address?.address ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RiderBloc, RiderState>(
      listenWhen: (previous, current) => widget.isFormAddress
          ? previous.fromAddress != current.fromAddress
          : previous.toAddress != current.toAddress,
      listener: (context, state) {
        final address = widget.isFormAddress
            ? state.fromAddress
            : state.toAddress;
        final text = address?.address ?? '';
        if (_controller.text != text) _controller.text = text;
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            const SizedBox(width: Dimensions.paddingSizeSmall),

            widget.isFormAddress
                ? Image.asset(
                    Images.liveMarker,
                    height: 16,
                    width: 16,
                    color: Theme.of(context).primaryColor,
                  )
                : Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Expanded(
              child: TypeAheadField<PredictionModel>(
                controller: _controller,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.search,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.streetAddress,
                    decoration: InputDecoration(
                      hintText: 'enter_pickup'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          style: BorderStyle.none,
                          width: 0,
                        ),
                      ),
                      hintStyle: Theme.of(context).textTheme.displayMedium!
                          .copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  );
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.isEmpty) return <PredictionModel>[];
                  final result = await getIt<LocationRepository>()
                      .searchLocation(pattern);
                  return result.getOrElse((_) => const <PredictionModel>[]);
                },
                itemBuilder: (context, PredictionModel suggestion) {
                  return Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Row(
                      children: [
                        widget.isFormAddress
                            ? Image.asset(
                                Images.liveMarker,
                                height: 16,
                                width: 16,
                                color: Theme.of(context).primaryColor,
                              )
                            : Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Expanded(
                          child: Text(
                            suggestion.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displayMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onSelected: (PredictionModel suggestion) {
                  _controller.text = suggestion.description ?? '';
                  context.read<RiderBloc>().add(
                    LocationFromPlaceSelected(
                      placeId: suggestion.placeId,
                      address: suggestion.description,
                      isFrom: widget.isFormAddress,
                    ),
                  );
                },
              ),
            ),

            BlocBuilder<RiderBloc, RiderState>(
              buildWhen: (previous, current) => widget.isFormAddress
                  ? previous.fromAddress != current.fromAddress
                  : previous.toAddress != current.toAddress,
              builder: (context, state) {
                final hasText = _controller.text != '';
                return hasText
                    ? InkWell(
                        onTap: () {
                          _controller.clear();
                          context.read<RiderBloc>().add(
                            AddressCleared(widget.isFormAddress),
                          );
                        },
                        child: const SizedBox(
                          height: 30,
                          width: 30,
                          child: Icon(Icons.clear, size: 16),
                        ),
                      )
                    : const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
