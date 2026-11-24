import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/support/widgets/web_help_support_widget.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/features/support/widgets/support_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'help_support'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        padding: ResponsiveHelper.isDesktop(context)
            ? EdgeInsets.zero
            : const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: FooterView(
            child: ResponsiveHelper.isDesktop(context)
                ? const SizedBox(
                    width: double.infinity,
                    height: 650,
                    child: WebSupportScreen(),
                  )
                : SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Image.asset(Images.supportImage, height: 120),
                        const SizedBox(height: 30),

                        Image.asset(Images.logo, width: 200),
                        const SizedBox(height: 40),

                        SupportButtonWidget(
                          icon: Icons.location_on,
                          title: 'address'.tr,
                          color: Colors.blue,
                          info:
                              getIt<SplashBloc>().state.configModel!.address,
                          onTap: () {},
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SupportButtonWidget(
                          icon: Icons.call,
                          title: 'call'.tr,
                          color: Colors.red,
                          info: getIt<SplashBloc>().state.configModel!.phone,
                          onTap: () async {
                            if (await canLaunchUrlString(
                              'tel:${getIt<SplashBloc>().state.configModel!.phone}',
                            )) {
                              launchUrlString(
                                'tel:${getIt<SplashBloc>().state.configModel!.phone}',
                              );
                            } else {
                              showCustomSnackBar(
                                '${'can_not_launch'.tr} ${getIt<SplashBloc>().state.configModel!.phone}',
                              );
                            }
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SupportButtonWidget(
                          icon: Icons.mail_outline,
                          title: 'email_us'.tr,
                          color: Colors.green,
                          info: getIt<SplashBloc>().state.configModel!.email,
                          onTap: () {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: getIt<SplashBloc>().state
                                  .configModel!
                                  .email,
                            );
                            launchUrlString(emailLaunchUri.toString());
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
