import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/controllers/theme_controller.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';

class CongratulationDialogue extends StatelessWidget {
  const CongratulationDialogue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Get.find<ThemeController>().darkTheme
                        ? Images.congratulationDark
                        : Images.congratulationLight,
                    width: 100,
                    height: 100,
                  ),

                  Text(
                    'congratulations'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                    ),
                    child: Text(
                      '${'you_will_earn'.tr} ${getIt<AuthRepository>().getEarningPoint()} ${'points_after_completing_this_order'.tr}',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).disabledColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomButton(
                    buttonText: 'visit_loyalty_points'.tr,
                    onPressed: () {
                      getIt<AuthRepository>().saveEarningPoint('');
                      Get.back();
                      Get.toNamed(RouteHelper.getLoyaltyRoute());
                    },
                  ),
                ],
              ),
            ),

            Positioned(
              top: 5,
              right: 5,
              child: InkWell(
                onTap: () {
                  getIt<AuthRepository>().saveEarningPoint('');
                  Get.back();
                },
                child: const Icon(Icons.clear, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
