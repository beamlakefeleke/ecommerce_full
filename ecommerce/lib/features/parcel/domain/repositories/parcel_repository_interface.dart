import 'package:ecommerce/core/network/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_category.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_instruction.dart';
import 'package:ecommerce/features/parcel/domain/entities/place_details.dart';
import 'package:ecommerce/features/parcel/domain/entities/video_content.dart';
import 'package:ecommerce/features/parcel/domain/entities/why_choose.dart';

abstract class ParcelRepositoryInterface {
  Future<Either<Failure, List<ParcelCategory>>> getParcelCategoryList();
  Future<Either<Failure, List<ParcelInstruction>>> getParcelInstructionList({int? offset});
  Future<Either<Failure, WhyChoose>> getWhyChooseDetails();
  Future<Either<Failure, VideoContent>> getVideoContentDetails();
  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String? placeID);
}