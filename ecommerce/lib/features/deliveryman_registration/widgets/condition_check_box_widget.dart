import 'package:ecommerce/features/deliveryman_registration/controllers/deliveryman_registration_controller.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ConditionCheckBoxWidget extends StatelessWidget {
  final bool forDeliveryMan;
  final bool forSignUp;
  const ConditionCheckBoxWidget({super.key, this.forDeliveryMan = false, this.forSignUp = true});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: forDeliveryMan ? MainAxisAlignment.start : MainAxisAlignment.center, children: [

      forDeliveryMan ? GetBuilder<DeliverymanRegistrationController>(builder: (dmRegController) {
        return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          final acceptTerms = state is AuthInitial ? state.acceptTerms : true;
          
          return Checkbox(
            activeColor: Theme.of(context).primaryColor,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            value: forSignUp ? acceptTerms : dmRegController.acceptTerms,
            onChanged: (bool? isChecked) => forSignUp ? context.read<AuthBloc>().add(const TermsToggled()) : dmRegController.toggleTerms(),
          );
        });
      }) : const SizedBox(),

      forDeliveryMan ? const SizedBox() : Text( '* ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
      Text(  forDeliveryMan ? 'i_agree_with_all_the'.tr :'by_login_i_agree_with_all_the'.tr, style: robotoRegular.copyWith(color: forDeliveryMan ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).hintColor, fontSize: forDeliveryMan ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall )),

      Expanded(child: InkWell(
        onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: Text('terms_conditions'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
        ),
      )),
    ]);
  }
}
