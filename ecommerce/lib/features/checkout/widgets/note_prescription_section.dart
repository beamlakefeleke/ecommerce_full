import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/common/widgets/image_picker_widget.dart';

class NoteAndPrescriptionSection extends StatelessWidget {
  final TextEditingController noteController;
  final int? storeId;
  const NoteAndPrescriptionSection({super.key, required this.noteController, this.storeId, });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('additional_note'.tr, style: robotoMedium),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      CustomTextField(
        controller: noteController,
        titleText: 'please_provide_extra_napkin'.tr,
        maxLines: 3,
        inputType: TextInputType.multiline,
        inputAction: TextInputAction.done,
        capitalization: TextCapitalization.sentences,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      storeId == null && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment! ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('prescription'.tr, style: robotoMedium),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Text(
              '(${'max_size_2_mb'.tr})',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          BlocBuilder<CheckoutBloc, CheckoutState>(
            builder: (context, state) {
              return ImagePickerWidget(
                image: '', rawFile: state.orderAttachment,
                onTap: () => context.read<CheckoutBloc>().add(const OrderAttachmentPicked()),
              );
            }
          ),
        ],
      ) : const SizedBox(),
    ]);
  }
}
