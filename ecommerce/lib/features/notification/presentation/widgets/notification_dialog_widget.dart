import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/notification/domain/entities/app_notification.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDialogWidget extends StatelessWidget {
  final AppNotification notification;
  const NotificationDialogWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              (notification.data!.image != null &&
                      notification.data!.image!.isNotEmpty)
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        color: Theme.of(context).primaryColor.withOpacity(0.20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        child: CustomImage(
                          isNotification: true,
                          image:
                              '${getIt<SplashBloc>().state.configModel!.baseUrls!.notificationImageUrl}/${notification.data!.image}',
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height:
                    (notification.data!.image != null &&
                        notification.data!.image!.isNotEmpty)
                    ? Dimensions.paddingSizeLarge
                    : 0,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Text(
                  notification.data!.title!,
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Text(
                  notification.data!.description!,
                  textAlign: TextAlign.start,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
