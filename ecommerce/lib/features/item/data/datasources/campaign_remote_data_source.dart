import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the campaign part of the item feature.
abstract class CampaignRemoteDataSource {
  Future<List<BasicCampaignModel>> getBasicCampaignList();
  Future<BasicCampaignModel> getCampaignDetails(String campaignID);
  Future<List<Item>> getItemCampaignList();
}

class CampaignRemoteDataSourceImpl implements CampaignRemoteDataSource {
  final ApiClient apiClient;

  CampaignRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<BasicCampaignModel>> getBasicCampaignList() async {
    final Response response = await apiClient.getData(
      AppConstants.basicCampaignUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<BasicCampaignModel> list = [];
      response.body.forEach((c) => list.add(BasicCampaignModel.fromJson(c)));
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<BasicCampaignModel> getCampaignDetails(String campaignID) async {
    final Response response = await apiClient.getData(
      '${AppConstants.basicCampaignDetailsUri}$campaignID',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return BasicCampaignModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Item>> getItemCampaignList() async {
    final Response response = await apiClient.getData(
      AppConstants.itemCampaignUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<Item> list = [];
      response.body.forEach((c) => list.add(Item.fromJson(c)));
      return list;
    }
    throw _exceptionFor(response);
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
