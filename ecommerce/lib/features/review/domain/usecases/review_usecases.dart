import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/review/domain/models/review_body_model.dart';
import 'package:ecommerce/features/review/domain/models/review_model.dart';
import 'package:ecommerce/features/review/domain/repositories/review_repository.dart';

class GetStoreReviewListUseCase implements UseCase<List<ReviewModel>, String?> {
  final ReviewRepository repository;
  GetStoreReviewListUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReviewModel>>> call(String? storeID) =>
      repository.getStoreReviewList(storeID);
}

class SubmitReviewUseCase implements UseCase<ResponseModel, ReviewBodyModel> {
  final ReviewRepository repository;
  SubmitReviewUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseModel>> call(ReviewBodyModel params) =>
      repository.submitReview(params);
}

class SubmitDeliveryManReviewUseCase
    implements UseCase<ResponseModel, ReviewBodyModel> {
  final ReviewRepository repository;
  SubmitDeliveryManReviewUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseModel>> call(ReviewBodyModel params) =>
      repository.submitDeliveryManReview(params);
}
