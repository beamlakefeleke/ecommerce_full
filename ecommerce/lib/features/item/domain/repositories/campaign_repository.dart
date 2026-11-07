import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';

abstract class CampaignRepository {
  Future<Either<Failure, List<BasicCampaignModel>>> getBasicCampaignList();
  Future<Either<Failure, BasicCampaignModel>> getCampaignDetails(
    String campaignID,
  );
  Future<Either<Failure, List<Item>>> getItemCampaignList();
}
