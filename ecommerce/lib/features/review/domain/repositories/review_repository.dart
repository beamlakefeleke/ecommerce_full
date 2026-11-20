import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/review/domain/models/review_body_model.dart';
import 'package:ecommerce/features/review/domain/models/review_model.dart';

/// Abstract contract for the review feature. Returns `Either<Failure, T>`;
/// raw exceptions never cross this boundary.
abstract class ReviewRepository {
  Future<Either<Failure, List<ReviewModel>>> getStoreReviewList(
    String? storeID,
  );
  Future<Either<Failure, ResponseModel>> submitReview(
    ReviewBodyModel reviewBody,
  );
  Future<Either<Failure, ResponseModel>> submitDeliveryManReview(
    ReviewBodyModel reviewBody,
  );
}
