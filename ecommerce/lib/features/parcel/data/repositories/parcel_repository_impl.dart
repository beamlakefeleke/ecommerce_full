import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_category.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_instruction.dart';
import 'package:ecommerce/features/parcel/domain/entities/place_details.dart';
import 'package:ecommerce/features/parcel/domain/entities/video_content.dart';
import 'package:ecommerce/features/parcel/domain/entities/why_choose.dart';
import 'package:ecommerce/features/parcel/domain/models/parcel_category_model.dart';
import 'package:ecommerce/features/parcel/domain/models/parcel_instruction_model.dart';
import 'package:ecommerce/features/parcel/domain/models/place_details_model.dart';
import 'package:ecommerce/features/parcel/domain/models/video_content_model.dart';
import 'package:ecommerce/features/parcel/domain/models/why_choose_model.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get_connect/connect.dart';

class ParcelRepositoryImpl implements ParcelRepositoryInterface {
  final ApiClient apiClient;

  ParcelRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String? placeID) async {
    try {
      Response response = await apiClient.getData('${AppConstants.placeDetailsUri}?placeid=$placeID');
      if (response.statusCode == 200) {
        return Right(PlaceDetailsModel.fromJson(response.body));
      } else {
        return Left(ServerFailure(response.statusText ?? 'Failed to get place details'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VideoContent>> getVideoContentDetails() async {
    try {
      Response response = await apiClient.getData(AppConstants.videoContentUri);
      if (response.statusCode == 200) {
        return Right(VideoContentModel.fromJson(response.body));
      } else {
        return Left(ServerFailure(response.statusText ?? 'Failed to get video content'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WhyChoose>> getWhyChooseDetails() async {
    try {
      Response response = await apiClient.getData(AppConstants.whyChooseUri);
      if (response.statusCode == 200) {
        return Right(WhyChooseModel.fromJson(response.body));
      } else {
        return Left(ServerFailure(response.statusText ?? 'Failed to get why choose details'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParcelCategory>>> getParcelCategoryList() async {
    try {
      Response response = await apiClient.getData(AppConstants.parcelCategoryUri);
      if (response.statusCode == 200) {
        List<ParcelCategory> parcelCategoryList = [];
        response.body.forEach((parcel) => parcelCategoryList.add(ParcelCategoryModel.fromJson(parcel)));
        return Right(parcelCategoryList);
      } else {
        return Left(ServerFailure(response.statusText ?? 'Failed to get parcel categories'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParcelInstruction>>> getParcelInstructionList({int? offset}) async {
    try {
      Response response = await apiClient.getData('${AppConstants.parcelInstructionUri}?limit=10&offset=$offset');
      if (response.statusCode == 200) {
        List<ParcelInstruction> parcelInstructionList = [];
        parcelInstructionList.addAll(ParcelInstructionModel.fromJson(response.body).data!);
        return Right(parcelInstructionList);
      } else {
        return Left(ServerFailure(response.statusText ?? 'Failed to get parcel instructions'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
