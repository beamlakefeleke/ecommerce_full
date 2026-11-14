part of 'onboard_bloc.dart';

enum OnboardStatus { initial, loading, loaded, error }

/// Single immutable state. A status enum is used (not a sealed hierarchy)
/// because the loaded slide list must survive across page-index changes
/// (rule 6).
class OnboardState extends Equatable {
  final OnboardStatus status;
  final List<OnBoarding> onBoardingList;
  final int selectedIndex;
  final String? errorMessage;

  const OnboardState({
    this.status = OnboardStatus.initial,
    this.onBoardingList = const [],
    this.selectedIndex = 0,
    this.errorMessage,
  });

  OnboardState copyWith({
    OnboardStatus? status,
    List<OnBoarding>? onBoardingList,
    int? selectedIndex,
    String? errorMessage,
  }) {
    return OnboardState(
      status: status ?? this.status,
      onBoardingList: onBoardingList ?? this.onBoardingList,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    onBoardingList,
    selectedIndex,
    errorMessage,
  ];
}
