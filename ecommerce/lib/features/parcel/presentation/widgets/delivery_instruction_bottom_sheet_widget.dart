import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_bloc.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_event.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_state.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';

class DeliveryInstructionBottomSheetWidget extends StatefulWidget {
  const DeliveryInstructionBottomSheetWidget({super.key});

  @override
  State<DeliveryInstructionBottomSheetWidget> createState() =>
      _DeliveryInstructionBottomSheetWidgetState();
}

class _DeliveryInstructionBottomSheetWidgetState
    extends State<DeliveryInstructionBottomSheetWidget> {
  // The note's text field is owned by this State, not the bloc (rule 4).
  final TextEditingController _customNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final parcelBloc = context.read<ParcelBloc>();
    parcelBloc.add(const ParcelInstructionRequested());
    // seed selection + note text from current bloc state
    parcelBloc.add(
      InstructionSelectedIndexSet(parcelBloc.state.selectedIndexNote),
    );
    _customNoteController.text = parcelBloc.state.customNote;
  }

  @override
  void dispose() {
    _customNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParcelBloc, ParcelState>(
      builder: (context, parcelState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minHeight: 250,
            maxWidth: 500,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusExtraLarge),
              topRight: Radius.circular(Dimensions.radiusExtraLarge),
            ),
          ),
          child: parcelState.parcelInstructionList != null
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).disabledColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          parcelState.parcelInstructionList!.isNotEmpty
                              ? Text(
                                  "choose_delivery_instructions".tr,
                                  style: robotoMedium,
                                )
                              : const SizedBox(),

                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Icon(
                              Icons.close,
                              color: Theme.of(context).disabledColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      parcelState.parcelInstructionList!.isNotEmpty
                          ? ListView.builder(
                              itemCount:
                                  parcelState.parcelInstructionList!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: Dimensions.paddingSizeDefault,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      context.read<ParcelBloc>().add(
                                        InstructionSelectedIndexSet(index),
                                      );
                                    },
                                    child: SelectedCardWidget(
                                      title: parcelState
                                          .parcelInstructionList![index]
                                          .instruction!,
                                      isSelect:
                                          parcelState
                                              .instructionSelectedIndex ==
                                          index,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Row(
                        children: [
                          parcelState.parcelInstructionList!.isNotEmpty
                              ? Text("or".tr, style: robotoMedium)
                              : const SizedBox(),
                          SizedBox(
                            width: parcelState.parcelInstructionList!.isNotEmpty
                                ? Dimensions.paddingSizeExtraSmall
                                : 0,
                          ),

                          Text("add_custom_note".tr, style: robotoMedium),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      CustomTextField(
                        titleText: "please_maintain_the_hygine".tr,
                        maxLines: 3,
                        controller: _customNoteController,
                        onChanged: (value) {
                          // keep the button's enabled state in sync
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      CustomButton(
                        onPressed:
                            (parcelState.instructionSelectedIndex != -1 ||
                                _customNoteController.text.isNotEmpty)
                            ? () {
                                // commit the selected instruction index, then
                                // the custom note (fallback to field text),
                                // mirroring the legacy setselectedIndex(null) +
                                // setCustomNote(null).
                                context.read<ParcelBloc>().add(
                                  const SelectedNoteIndexSet(null),
                                );
                                context.read<ParcelBloc>().add(
                                  CustomNoteSet(
                                    null,
                                    controllerText: _customNoteController.text,
                                  ),
                                );
                                Get.back();
                              }
                            : null,
                        buttonText: 'apply'.tr,
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class SelectedCardWidget extends StatelessWidget {
  final bool isSelect;
  final String title;
  const SelectedCardWidget({
    super.key,
    required this.isSelect,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(
          color: Theme.of(context).disabledColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSelect ? Icons.check_circle : Icons.radio_button_off,
            color: isSelect
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
            size: 25,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Text(
              title,
              style: robotoRegular.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
