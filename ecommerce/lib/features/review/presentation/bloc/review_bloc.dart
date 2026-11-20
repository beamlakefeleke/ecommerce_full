import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/review/domain/usecases/review_usecases.dart';
import 'package:ecommerce/features/review/presentation/bloc/review_event.dart';
import 'package:ecommerce/features/review/presentation/bloc/review_state.dart';

/// Screen-scoped bloc for the review feature. Provided per-screen via
/// [BlocProvider]; not cross-cutting. Input is only via `add(Event)`; no
/// navigation / snackbars inside the bloc — the UI reacts to [actionStatus] /
/// [actionType] through a `BlocListener`.
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetStoreReviewListUseCase getStoreReviewList;
  final SubmitReviewUseCase submitReview;
  final SubmitDeliveryManReviewUseCase submitDeliveryManReview;

  ReviewBloc({
    required this.getStoreReviewList,
    required this.submitReview,
    required this.submitDeliveryManReview,
  }) : super(const ReviewState()) {
    on<StoreReviewListRequested>(_onStoreReviewListRequested);
    on<ReviewRatingDataInitialized>(_onRatingDataInitialized);
    on<ReviewItemRatingSet>(_onItemRatingSet);
    on<ReviewItemCommentSet>(_onItemCommentSet);
    on<DeliveryManRatingSet>(_onDeliveryManRatingSet);
    on<ItemReviewSubmitted>(_onItemReviewSubmitted);
    on<DeliveryManReviewSubmitted>(_onDeliveryManReviewSubmitted);
  }

  Future<void> _onStoreReviewListRequested(
    StoreReviewListRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(
      state.copyWith(
        storeReviewStatus: StoreReviewStatus.loading,
        clearStoreReviewList: true,
      ),
    );
    final result = await getStoreReviewList(event.storeID);
    result.fold(
      (failure) => emit(
        state.copyWith(
          storeReviewStatus: StoreReviewStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (list) => emit(
        state.copyWith(
          storeReviewStatus: StoreReviewStatus.loaded,
          storeReviewList: list,
        ),
      ),
    );
  }

  void _onRatingDataInitialized(
    ReviewRatingDataInitialized event,
    Emitter<ReviewState> emit,
  ) {
    final int count = event.orderDetailsList.length;
    emit(
      state.copyWith(
        ratingList: List.filled(count, 0),
        reviewList: List.filled(count, ''),
        loadingList: List.filled(count, false),
        submitList: List.filled(count, false),
        deliveryManRating: 0,
      ),
    );
  }

  void _onItemRatingSet(
    ReviewItemRatingSet event,
    Emitter<ReviewState> emit,
  ) {
    final updated = List<int>.from(state.ratingList);
    updated[event.index] = event.rating;
    emit(state.copyWith(ratingList: updated));
  }

  void _onItemCommentSet(
    ReviewItemCommentSet event,
    Emitter<ReviewState> emit,
  ) {
    final updated = List<String>.from(state.reviewList);
    updated[event.index] = event.comment;
    emit(state.copyWith(reviewList: updated));
  }

  void _onDeliveryManRatingSet(
    DeliveryManRatingSet event,
    Emitter<ReviewState> emit,
  ) {
    emit(state.copyWith(deliveryManRating: event.rating));
  }

  Future<void> _onItemReviewSubmitted(
    ItemReviewSubmitted event,
    Emitter<ReviewState> emit,
  ) async {
    // Mark this slot as loading.
    final loading = List<bool>.from(state.loadingList);
    loading[event.index] = true;
    emit(state.copyWith(loadingList: loading));

    final result = await submitReview(event.reviewBody);

    final loadingDone = List<bool>.from(state.loadingList);
    loadingDone[event.index] = false;

    result.fold(
      (failure) => emit(
        state.copyWith(
          loadingList: loadingDone,
          actionStatus: ReviewActionStatus.failure,
          actionType: ReviewActionType.item,
          actionMessage: failure.message,
          actionIndex: event.index,
        ),
      ),
      (response) {
        final submitted = List<bool>.from(state.submitList);
        submitted[event.index] = true;
        final comments = List<String>.from(state.reviewList);
        comments[event.index] = '';
        emit(
          state.copyWith(
            loadingList: loadingDone,
            submitList: submitted,
            reviewList: comments,
            actionStatus: ReviewActionStatus.success,
            actionType: ReviewActionType.item,
            actionMessage: response.message,
            actionIndex: event.index,
          ),
        );
      },
    );
  }

  Future<void> _onDeliveryManReviewSubmitted(
    DeliveryManReviewSubmitted event,
    Emitter<ReviewState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await submitDeliveryManReview(event.reviewBody);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: ReviewActionStatus.failure,
          actionType: ReviewActionType.deliveryMan,
          actionMessage: failure.message,
          actionIndex: -1,
        ),
      ),
      (response) => emit(
        state.copyWith(
          isLoading: false,
          deliveryManRating: 0,
          actionStatus: ReviewActionStatus.success,
          actionType: ReviewActionType.deliveryMan,
          actionMessage: response.message,
          actionIndex: -1,
        ),
      ),
    );
  }
}
