import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/html_type.dart';

/// Raw API access for the html feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class HtmlRemoteDataSource {
  Future<String> getHtmlText(HtmlType htmlType);
}

class HtmlRemoteDataSourceImpl implements HtmlRemoteDataSource {
  final ApiClient apiClient;

  HtmlRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> getHtmlText(HtmlType htmlType) async {
    final Response response = await apiClient.getData(
      _uriFor(htmlType),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        AppConstants.localizationKey:
            Get.find<LocalizationController>().locale.languageCode,
      },
      handleError: false,
    );
    if (response.statusCode == 200) {
      if (response.body != null &&
          response.body.isNotEmpty &&
          response.body is String) {
        return response.body;
      }
      return '';
    }
    throw _exceptionFor(response);
  }

  String _uriFor(HtmlType htmlType) {
    switch (htmlType) {
      case HtmlType.termsAndCondition:
        return AppConstants.termsAndConditionUri;
      case HtmlType.privacyPolicy:
        return AppConstants.privacyPolicyUri;
      case HtmlType.aboutUs:
        return AppConstants.aboutUsUri;
      case HtmlType.shippingPolicy:
        return AppConstants.shippingPolicyUri;
      case HtmlType.cancellation:
        return AppConstants.cancellationUri;
      case HtmlType.refund:
        return AppConstants.refundUri;
    }
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
