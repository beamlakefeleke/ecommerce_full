import 'package:get/get_connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/cart/data/models/online_cart_model.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/util/app_constants.dart';

abstract class CartRemoteDataSource {
  Future<List<OnlineCartModel>> addToCart(OnlineCart cart);
  Future<List<OnlineCartModel>> updateCart(OnlineCart cart);
  Future<bool> updateCartQuantity(int cartId, double price, int quantity);
  Future<List<OnlineCartModel>> getCartList();
  Future<bool> removeCartItem(int cartId);
  Future<bool> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OnlineCartModel>> addToCart(OnlineCart cart) async {
    final Response response = await apiClient.postData(
      '${AppConstants.addCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      cart.toJson(),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return _parseCartList(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<OnlineCartModel>> updateCart(OnlineCart cart) async {
    final Response response = await apiClient.putData(
      '${AppConstants.updateCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      cart.toJson(),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return _parseCartList(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<bool> updateCartQuantity(
    int cartId,
    double price,
    int quantity,
  ) async {
    final Response response = await apiClient.putData(
      '${AppConstants.updateCartUri}/$cartId${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      {'price': price, 'quantity': quantity},
      handleError: false,
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<OnlineCartModel>> getCartList() async {
    final Response response = await apiClient.getData(
      '${AppConstants.getCartListUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return _parseCartList(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<bool> removeCartItem(int cartId) async {
    final Response response = await apiClient.deleteData(
      '${AppConstants.removeItemCartUri}/$cartId${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      handleError: false,
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> clearCart() async {
    final Response response = await apiClient.deleteData(
      '${AppConstants.removeAllCartUri}${!AuthHelper.isLoggedIn() ? '?guest_id=${AuthHelper.getGuestId()}' : ''}',
      handleError: false,
    );
    return response.statusCode == 200;
  }

  List<OnlineCartModel> _parseCartList(dynamic body) {
    final List<OnlineCartModel> list = [];
    body.forEach((v) => list.add(OnlineCartModel.fromJson(v)));
    return list;
  }

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
