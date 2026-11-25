import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) {
    if (response.statusCode == 401) {
      getIt<AuthRepository>().clearSharedData();
      getIt<FavouriteBloc>().add(const FavouriteCleared());
      Get.offAllNamed(
        GetPlatform.isWeb
            ? RouteHelper.getInitialRoute()
            : RouteHelper.getSignInRoute(RouteHelper.splash),
      );
    } else {
      showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar);
    }
  }
}
