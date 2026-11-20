import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/review/domain/models/review_model.dart';

enum StoreReviewStatus { initial, loading, loaded, error }

/// One-shot outcome of the last submit (item or delivery-man), surfaced to the
/// UI via a `BlocListener`.
enum ReviewActionStatus { none, success, failure }

/// Which submit produced the current [ReviewActionStatus] / [actionMessage].
enum ReviewActionType { none, item, deliveryMan }

/// Single immutable state. Status enums are used (not a sealed hierarchy)
/// because the store list, the per-item working lists and the delivery-man
/// rating must all coexist and survive across submits (rule 6).
class ReviewState extends Equatable {
  final StoreReviewStatus storeReviewStatus;
  final List<ReviewModel> storeReviewList;

  /// Per-order-item working state (index-aligned with the order detail list).
  final List<int> ratingList;
  final List<String> reviewList;
  final List<bool> loadingList;
  final List<bool> submitList;

  final int deliveryManRating;

  /// True while a delivery-man review submit is in flight.
  final bool isLoading;

  final ReviewActionStatus actionStatus;
  final ReviewActionType actionType;
  final String? actionMessage;

  /// Index of the item whose submit produced [actionStatus] (-1 for none / dm).
  final int actionIndex;

  final String? errorMessage;

  const ReviewState({
    this.storeReviewStatus = StoreReviewStatus.initial,
    this.storeReviewList = const [],
    this.ratingList = const [],
    this.reviewList = const [],
    this.loadingList = const [],
    this.submitList = const [],
    this.deliveryManRating = 0,
    this.isLoading = false,
    this.actionStatus = ReviewActionStatus.none,
    this.actionType = ReviewActionType.none,
    this.actionMessage,
    this.actionIndex = -1,
    this.errorMessage,
  });

  ReviewState copyWith({
    StoreReviewStatus? storeReviewStatus,
    List<ReviewModel>? storeReviewList,
    bool clearStoreReviewList = false,
    List<int>? ratingList,
    List<String>? reviewList,
    List<bool>? loadingList,
    List<bool>? submitList,
    int? deliveryManRating,
    bool? isLoading,
    ReviewActionStatus? actionStatus,
    ReviewActionType? actionType,
    String? actionMessage,
    int? actionIndex,
    String? errorMessage,
  }) {
    return ReviewState(
      storeReviewStatus: storeReviewStatus ?? this.storeReviewStatus,
      storeReviewList: clearStoreReviewList
          ? const []
          : (storeReviewList ?? this.storeReviewList),
      ratingList: ratingList ?? this.ratingList,
      reviewList: reviewList ?? this.reviewList,
      loadingList: loadingList ?? this.loadingList,
      submitList: submitList ?? this.submitList,
      deliveryManRating: deliveryManRating ?? this.deliveryManRating,
      isLoading: isLoading ?? this.isLoading,
      actionStatus: actionStatus ?? this.actionStatus,
      actionType: actionType ?? this.actionType,
      actionMessage: actionMessage,
      actionIndex: actionIndex ?? this.actionIndex,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    storeReviewStatus,
    storeReviewList,
    ratingList,
    reviewList,
    loadingList,
    submitList,
    deliveryManRating,
    isLoading,
    actionStatus,
    actionType,
    actionMessage,
    actionIndex,
    errorMessage,
  ];
}
