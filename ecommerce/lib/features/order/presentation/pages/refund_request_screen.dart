import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';

class RefundRequestScreen extends StatefulWidget {
  final String? orderId;
  const RefundRequestScreen({super.key, required this.orderId});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const RefundReasonSelected(0));
    context.read<OrderBloc>().add(const RefundImagePicked(remove: true));
    context.read<OrderBloc>().add(const RefundReasonsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'refund_request'.tr),
      body: SafeArea(
        child: BlocConsumer<OrderBloc, OrderState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus &&
              current.actionType == OrderActionType.refundSubmit,
          listener: (context, state) {
            if (state.actionStatus == OrderActionStatus.success) {
              showCustomSnackBar(state.actionMessage, isError: false);
              Get.offAllNamed(RouteHelper.getInitialRoute());
            } else if (state.actionStatus == OrderActionStatus.failure) {
              showCustomSnackBar(
                state.actionMessage == 'please_select_reason'
                    ? 'please_select_reason'.tr
                    : state.actionMessage,
              );
            }
          },
          builder: (context, state) {
            return Center(
              child:
                  (state.refundReasons != null &&
                      state.refundReasons!.isNotEmpty)
                  ? Container(
                      width: context.width > 700 ? 700 : context.width,
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'what_is_wrong_with_this_order'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeDefault,
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                      border: Border.all(
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                    child: DropdownButton<String>(
                                      value:
                                          state.refundReasons![state
                                              .selectedReasonIndex],
                                      items: state.refundReasons!.map((
                                        String? items,
                                      ) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items!.tr),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        context.read<OrderBloc>().add(
                                          RefundReasonSelected(
                                            state.refundReasons!.indexOf(value),
                                          ),
                                        );
                                        if (_noteController.text.isNotEmpty) {
                                          _noteController.text = '';
                                        }
                                        if (state.refundImage != null) {
                                          context.read<OrderBloc>().add(
                                            const RefundImagePicked(
                                              remove: true,
                                            ),
                                          );
                                        }
                                      },
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),

                                  state.selectedReasonIndex != 0
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'additional_note'.tr,
                                              style: robotoMedium,
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeDefault,
                                            ),

                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusSmall,
                                                    ),
                                                border: Border.all(
                                                  color: Theme.of(
                                                    context,
                                                  ).disabledColor,
                                                ),
                                              ),
                                              child: CustomTextField(
                                                controller: _noteController,
                                                titleText:
                                                    'ex_please_provide_any_note'
                                                        .tr,
                                                maxLines: 3,
                                                inputType:
                                                    TextInputType.multiline,
                                                inputAction:
                                                    TextInputAction.newline,
                                                capitalization:
                                                    TextCapitalization
                                                        .sentences,
                                              ),
                                            ),

                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeLarge,
                                            ),

                                            DottedBorder(
                                              options: RoundedRectDottedBorderOptions(
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                              strokeWidth: 2,
                                              strokeCap: StrokeCap.butt,
                                              dashPattern: const [8, 5],
                                              padding: const EdgeInsets.all(0),
                                              radius: const Radius.circular(
                                                Dimensions.radiusSmall,
                                              ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall,
                                                        ),
                                                    child:
                                                        state.refundImage !=
                                                            null
                                                        ? GetPlatform.isWeb
                                                              ? Image.network(
                                                                  state.refundImage!
                                                                      .path,
                                                                  width: context
                                                                      .width,
                                                                  height: 150,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.file(
                                                                  File(
                                                                    state.refundImage!
                                                                        .path,
                                                                  ),
                                                                  width: context
                                                                      .width,
                                                                  height: 150,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                        : InkWell(
                                                            onTap: () =>
                                                                context.read<OrderBloc>().add(const RefundImagePicked()),
                                                            child: Container(
                                                              width:
                                                                  context.width,
                                                              height: 150,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .cloud_download_rounded,
                                                                    size: 34,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).disabledColor,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: Dimensions
                                                                        .paddingSizeSmall,
                                                                  ),

                                                                  Text(
                                                                    'upload_image'
                                                                        .tr,
                                                                    style: robotoMedium.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeExtraLarge,
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).disabledColor,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                  state.refundImage !=
                                                          null
                                                      ? Positioned(
                                                          bottom: 0,
                                                          right: 0,
                                                          top: 0,
                                                          left: 0,
                                                          child: InkWell(
                                                            onTap: () =>
                                                                context.read<OrderBloc>().add(const RefundImagePicked()),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusSmall,
                                                                    ),
                                                              ),
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets.all(
                                                                      25,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                    width: 2,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).disabledColor,
                                                                  ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .camera_alt,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).disabledColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ),

                          CustomButton(
                            buttonText: 'submit_refund_request'.tr,
                            isLoading: state.isLoading,
                            onPressed: () =>
                                context.read<OrderBloc>().add(RefundRequestSubmitted(note: _noteController.text.trim(), orderId: widget.orderId)),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
