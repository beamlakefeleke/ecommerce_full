import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/onboard/domain/entities/on_boarding.dart';
import 'package:ecommerce/features/onboard/domain/usecases/get_onboarding_list_usecase.dart';

part 'onboard_event.dart';
part 'onboard_state.dart';

class OnboardBloc extends Bloc<OnboardEvent, OnboardState> {
  final GetOnBoardingListUseCase getOnBoardingList;

  OnboardBloc({required this.getOnBoardingList})
    : super(const OnboardState()) {
    on<OnBoardingListRequested>(_onListRequested);
    on<OnBoardingIndexChanged>(_onIndexChanged);
  }

  Future<void> _onListRequested(
    OnBoardingListRequested event,
    Emitter<OnboardState> emit,
  ) async {
    emit(state.copyWith(status: OnboardStatus.loading));
    final result = await getOnBoardingList(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OnboardStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (list) => emit(
        state.copyWith(status: OnboardStatus.loaded, onBoardingList: list),
      ),
    );
  }

  void _onIndexChanged(
    OnBoardingIndexChanged event,
    Emitter<OnboardState> emit,
  ) {
    emit(state.copyWith(selectedIndex: event.index));
  }
}
