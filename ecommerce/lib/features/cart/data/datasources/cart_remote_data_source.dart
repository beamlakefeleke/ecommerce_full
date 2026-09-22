import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/cart/domain/models/online_cart_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  CartRemoteDataSource({required this.apiClient, required this.sharedPreferences});

  Future<List<OnlineCartModel>> getCartDataOnline() async {
    Map<String, String>? header = {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: AppConstants.languages[0].languageCode!,
      AppConstants.moduleId: '${ModuleHelper.getCacheModule()?.id}',
      'Authorization': 'Bearer ${sharedPreferences.getString(AppConstants.token)}'
    };

    Response response = await apiClient.getData(
      '${AppConstants.getCartListUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      headers: ModuleHelper.getModule()?.id == null ? header : null,
    );

    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      return onlineCartList;
    } else {
      throw Exception(response.statusText);
    }
  }

  Future<List<OnlineCartModel>> addToCartOnline(Map<String, dynamic> cartJson) async {
    Response response = await apiClient.postData(
      '${AppConstants.addCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      cartJson,
    );
    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      return onlineCartList;
    } else {
      throw Exception(response.statusText);
    }
  }

  Future<List<OnlineCartModel>> updateCartOnline(Map<String, dynamic> body) async {
    Response response = await apiClient.postData(
      '${AppConstants.updateCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      body,
    );
    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach((cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      return onlineCartList;
    } else {
      throw Exception(response.statusText);
    }
  }

  Future<bool> updateCartQuantityOnline(int cartId, double price, int quantity) async {
    Map<String, dynamic> data = {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
    };
    Response response = await apiClient.postData(
      '${AppConstants.updateCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      data,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.statusText);
    }
  }

  Future<bool> removeCartItemOnline(int cartId) async {
    Response response = await apiClient.deleteData(
      '${AppConstants.removeItemCartUri}?cart_id=$cartId${!AuthHelper.isLoggedIn() ? '&guest_id=${AuthHelper.getGuestId()}' : ''}',
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.statusText);
    }
  }

  Future<bool> clearCartOnline() async {
    Response response = await apiClient.deleteData(
      '${AppConstants.removeAllCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(response.statusText);
    }
  }
}
