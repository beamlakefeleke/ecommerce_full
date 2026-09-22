import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) {
    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      getIt<FavouriteBloc>().add(const FavouriteLocalCleared());
      Get.offAllNamed(GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSignInRoute(RouteHelper.splash));
    }else {
      showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar);
    }
  }
}
