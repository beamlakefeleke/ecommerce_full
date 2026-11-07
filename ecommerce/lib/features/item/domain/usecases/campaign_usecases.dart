import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/item/domain/repositories/campaign_repository.dart';

class GetBasicCampaignListUseCase
    implements UseCase<List<BasicCampaignModel>, NoParams> {
  final CampaignRepository repository;
  GetBasicCampaignListUseCase(this.repository);
  @override
  Future<Either<Failure, List<BasicCampaignModel>>> call(NoParams params) =>
      repository.getBasicCampaignList();
}

class CampaignIdParams extends Equatable {
  final String campaignID;
  const CampaignIdParams(this.campaignID);
  @override
  List<Object?> get props => [campaignID];
}

class GetCampaignDetailsUseCase
    implements UseCase<BasicCampaignModel, CampaignIdParams> {
  final CampaignRepository repository;
  GetCampaignDetailsUseCase(this.repository);
  @override
  Future<Either<Failure, BasicCampaignModel>> call(CampaignIdParams params) =>
      repository.getCampaignDetails(params.campaignID);
}

class GetItemCampaignListUseCase implements UseCase<List<Item>, NoParams> {
  final CampaignRepository repository;
  GetItemCampaignListUseCase(this.repository);
  @override
  Future<Either<Failure, List<Item>>> call(NoParams params) =>
      repository.getItemCampaignList();
}
