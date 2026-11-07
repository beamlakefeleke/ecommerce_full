import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/item/data/datasources/campaign_remote_data_source.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/item/domain/repositories/campaign_repository.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignRemoteDataSource remoteDataSource;

  CampaignRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BasicCampaignModel>>> getBasicCampaignList() =>
      _guard(() => remoteDataSource.getBasicCampaignList());

  @override
  Future<Either<Failure, BasicCampaignModel>> getCampaignDetails(
    String campaignID,
  ) => _guard(() => remoteDataSource.getCampaignDetails(campaignID));

  @override
  Future<Either<Failure, List<Item>>> getItemCampaignList() =>
      _guard(() => remoteDataSource.getItemCampaignList());
}
