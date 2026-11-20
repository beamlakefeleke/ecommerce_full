import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/review/data/datasources/review_remote_data_source.dart';
import 'package:ecommerce/features/review/domain/models/review_body_model.dart';
import 'package:ecommerce/features/review/domain/models/review_model.dart';
import 'package:ecommerce/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReviewModel>>> getStoreReviewList(
    String? storeID,
  ) => _guard(() => remoteDataSource.getStoreReviewList(storeID));

  @override
  Future<Either<Failure, ResponseModel>> submitReview(
    ReviewBodyModel reviewBody,
  ) => _guard(() => remoteDataSource.submitReview(reviewBody));

  @override
  Future<Either<Failure, ResponseModel>> submitDeliveryManReview(
    ReviewBodyModel reviewBody,
  ) => _guard(() => remoteDataSource.submitDeliveryManReview(reviewBody));

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
