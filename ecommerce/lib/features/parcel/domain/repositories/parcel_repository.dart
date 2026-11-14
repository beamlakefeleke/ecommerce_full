import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_category_model.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_instruction_model.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/parcel/data/models/video_content_model.dart';
import 'package:ecommerce/features/parcel/data/models/why_choose_model.dart';

/// Abstract contract for the parcel feature.
///
/// Offline methods / dm-tip / distance / place-order are served by the
/// migrated `CheckoutRepository`, not this contract (same split the legacy
/// `ParcelService` used).
abstract class ParcelRepository {
  Future<Either<Failure, List<ParcelCategoryModel>>> getParcelCategory();
  Future<Either<Failure, List<Data>>> getParcelInstruction(int offset);
  Future<Either<Failure, WhyChooseModel?>> getWhyChooseDetails();
  Future<Either<Failure, VideoContentModel?>> getVideoContentDetails();
  Future<Either<Failure, PlaceDetailsModel>> getPlaceDetails(String? placeId);
}
