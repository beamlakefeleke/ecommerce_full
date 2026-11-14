part of 'onboard_bloc.dart';

sealed class OnboardEvent extends Equatable {
  const OnboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load the onboarding slides.
class OnBoardingListRequested extends OnboardEvent {
  const OnBoardingListRequested();
}

/// The user swiped to a new slide.
class OnBoardingIndexChanged extends OnboardEvent {
  final int index;

  const OnBoardingIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}
