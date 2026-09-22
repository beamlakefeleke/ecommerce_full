import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class GuestButtonWidget extends StatelessWidget {
  const GuestButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthGuestSuccess) {
          Get.find<ProfileController>().setForceFullyUserEmpty();
          Navigator.pushReplacementNamed(context, RouteHelper.getInitialRoute());
        }
      },
      builder: (context, state) {
        final guestLoading = state is AuthGuestLoading;

        return !guestLoading ? TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(1, 40),
          ),
          onPressed: () {
            context.read<AuthBloc>().add(const GuestLoginRequested());
          },
          child: RichText(text: TextSpan(children: [
            TextSpan(text: '${'continue_as'.tr} ', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
            TextSpan(text: 'guest'.tr, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
          ])),
        ) : const Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()));
      }
    );
  }
}
