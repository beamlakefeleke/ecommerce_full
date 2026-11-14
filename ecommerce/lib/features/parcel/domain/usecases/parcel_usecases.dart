import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_category_model.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_instruction_model.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/parcel/data/models/video_content_model.dart';
import 'package:ecommerce/features/parcel/data/models/why_choose_model.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository.dart';

/// Parcel category list (shown on the category screen).
class GetParcelCategoryUseCase
    implements UseCase<List<ParcelCategoryModel>, NoParams> {
  final ParcelRepository repository;
  GetParcelCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParcelCategoryModel>>> call(NoParams params) =>
      repository.getParcelCategory();
}

/// Paginated parcel delivery instructions (bottom sheet on the request screen).
class GetParcelInstructionUseCase implements UseCase<List<Data>, int> {
  final ParcelRepository repository;
  GetParcelInstructionUseCase(this.repository);

  @override
  Future<Either<Failure, List<Data>>> call(int offset) =>
      repository.getParcelInstruction(offset);
}

/// "Why choose" banner block (parcel landing).
class GetWhyChooseDetailsUseCase implements UseCase<WhyChooseModel?, NoParams> {
  final ParcelRepository repository;
  GetWhyChooseDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, WhyChooseModel?>> call(NoParams params) =>
      repository.getWhyChooseDetails();
}

/// Promotional video/content banner block (parcel landing).
class GetVideoContentDetailsUseCase
    implements UseCase<VideoContentModel?, NoParams> {
  final ParcelRepository repository;
  GetVideoContentDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, VideoContentModel?>> call(NoParams params) =>
      repository.getVideoContentDetails();
}

/// Google Places details for a selected prediction (used when picking a
/// pickup / destination location from search).
class GetPlaceDetailsUseCase implements UseCase<PlaceDetailsModel, String?> {
  final ParcelRepository repository;
  GetPlaceDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, PlaceDetailsModel>> call(String? placeId) =>
      repository.getPlaceDetails(placeId);
}
