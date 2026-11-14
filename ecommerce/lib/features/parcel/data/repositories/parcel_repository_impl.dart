import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/parcel/data/datasources/parcel_remote_data_source.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_category_model.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_instruction_model.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/parcel/data/models/video_content_model.dart';
import 'package:ecommerce/features/parcel/data/models/why_choose_model.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository.dart';

class ParcelRepositoryImpl implements ParcelRepository {
  final ParcelRemoteDataSource remoteDataSource;

  ParcelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ParcelCategoryModel>>> getParcelCategory() =>
      _guard(() => remoteDataSource.getParcelCategory());

  @override
  Future<Either<Failure, List<Data>>> getParcelInstruction(int offset) =>
      _guard(() => remoteDataSource.getParcelInstruction(offset));

  @override
  Future<Either<Failure, WhyChooseModel?>> getWhyChooseDetails() =>
      _guard(() => remoteDataSource.getWhyChooseDetails());

  @override
  Future<Either<Failure, VideoContentModel?>> getVideoContentDetails() =>
      _guard(() => remoteDataSource.getVideoContentDetails());

  @override
  Future<Either<Failure, PlaceDetailsModel>> getPlaceDetails(String? placeId) =>
      _guard(() => remoteDataSource.getPlaceDetails(placeId));

  /// Shared try/catch that maps data-layer exceptions to [Failure]s.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
