import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:flutter_facebook_auth_platform_interface/flutter_facebook_auth_platform_interface.dart' show ClassicToken;
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialLoginWidget extends StatelessWidget {
  const SocialLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    return Get.find<SplashController>().configModel != null &&
            Get.find<SplashController>().configModel!.socialLogin!.isNotEmpty &&
            (Get.find<SplashController>()
                    .configModel!
                    .socialLogin![0]
                    .status! ||
                Get.find<SplashController>()
                    .configModel!
                    .socialLogin![1]
                    .status!)
        ? Column(
            children: [
              Center(
                child: Text(
                  ResponsiveHelper.isDesktop(context)
                      ? 'or_continue_with'.tr
                      : 'social_login'.tr,
                  style: robotoMedium.copyWith(
                    color: ResponsiveHelper.isDesktop(context)
                        ? Theme.of(context).hintColor
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Get.find<SplashController>()
                          .configModel!
                          .socialLogin![0]
                          .status!
                      ? InkWell(
                          onTap: () async {
                            GoogleSignInAccount? googleAccount =
                                await googleSignIn.authenticate();
                            GoogleSignInAuthentication auth = googleAccount!.authentication;
                            if (!context.mounted) return;
                            context.read<AuthBloc>().add(SocialLoginRequested(
                                body: SocialLoginBody(
                              email: googleAccount.email,
                              token: auth.idToken,
                              uniqueId: googleAccount.id,
                              medium: 'google',
                            )));
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(Images.google),
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                    width:
                        Get.find<SplashController>()
                                .configModel!
                                .socialLogin![0]
                                .status!
                            ? Dimensions.paddingSizeSmall
                            : 0,
                  ),

                  Get.find<SplashController>()
                          .configModel!
                          .socialLogin![1]
                          .status!
                      ? InkWell(
                          onTap: () async {
                            LoginResult result = await FacebookAuth.instance
                                .login();
                            if (result.status == LoginStatus.success) {
                              Map userData = await FacebookAuth.instance
                                  .getUserData();
                              if (!context.mounted) return;
                              context.read<AuthBloc>().add(SocialLoginRequested(
                                  body: SocialLoginBody(
                                email: userData['email'],
                                token: result.accessToken!.tokenString,
                                uniqueId: (result.accessToken! as ClassicToken).userId,
                                medium: 'facebook',
                              )));
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(Images.socialFacebook),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Get.find<SplashController>()
                              .configModel!
                              .appleLogin!
                              .isNotEmpty &&
                          Get.find<SplashController>()
                              .configModel!
                              .appleLogin![0]
                              .status! &&
                          !GetPlatform.isAndroid &&
                          !GetPlatform.isWeb
                      ? InkWell(
                          onTap: () async {
                            final credential =
                                await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                  webAuthenticationOptions:
                                      WebAuthenticationOptions(
                                        clientId: Get.find<SplashController>()
                                            .configModel!
                                            .appleLogin![0]
                                            .clientId!,
                                        redirectUri: Uri.parse(
                                          'https://6ammart-web.6amtech.com/apple',
                                        ),
                                      ),
                                );
                            if (!context.mounted) return;
                            context.read<AuthBloc>().add(SocialLoginRequested(
                                body: SocialLoginBody(
                              email: credential.email,
                              token: credential.authorizationCode,
                              uniqueId: credential.authorizationCode,
                              medium: 'apple',
                            )));
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(Images.appleLogo),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          )
        : const SizedBox();
  }
}
