import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/review/domain/models/review_body_model.dart';

sealed class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or refresh) a store's review list.
class StoreReviewListRequested extends ReviewEvent {
  final String? storeID;

  const StoreReviewListRequested(this.storeID);

  @override
  List<Object?> get props => [storeID];
}

/// Seed the per-item rating/review/loading/submit lists for a rate-review
/// screen (one slot per order detail).
class ReviewRatingDataInitialized extends ReviewEvent {
  final List<OrderDetailsModel> orderDetailsList;

  const ReviewRatingDataInitialized(this.orderDetailsList);

  @override
  List<Object?> get props => [orderDetailsList];
}

class ReviewItemRatingSet extends ReviewEvent {
  final int index;
  final int rating;

  const ReviewItemRatingSet(this.index, this.rating);

  @override
  List<Object?> get props => [index, rating];
}

class ReviewItemCommentSet extends ReviewEvent {
  final int index;
  final String comment;

  const ReviewItemCommentSet(this.index, this.comment);

  @override
  List<Object?> get props => [index, comment];
}

class DeliveryManRatingSet extends ReviewEvent {
  final int rating;

  const DeliveryManRatingSet(this.rating);

  @override
  List<Object?> get props => [rating];
}

/// Submit the review for the item at [index].
class ItemReviewSubmitted extends ReviewEvent {
  final int index;
  final ReviewBodyModel reviewBody;

  const ItemReviewSubmitted(this.index, this.reviewBody);

  @override
  List<Object?> get props => [index, reviewBody];
}

class DeliveryManReviewSubmitted extends ReviewEvent {
  final ReviewBodyModel reviewBody;

  const DeliveryManReviewSubmitted(this.reviewBody);

  @override
  List<Object?> get props => [reviewBody];
}
