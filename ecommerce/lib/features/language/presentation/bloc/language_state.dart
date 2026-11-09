import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/language/domain/entities/language.dart';
import 'package:ecommerce/util/app_constants.dart';

/// One-shot signal for the "a language was applied" side effects (locale sync
/// + zone/landing reload), consumed via `BlocListener` in `main.dart`.
enum LanguageChangeStatus { none, applied }

/// Single immutable state (rule 6). A status enum is used rather than a sealed
/// hierarchy because the locale/isLtr/list/selectedIndex all coexist and
/// survive across select/search/apply actions.
class LanguageState extends Equatable {
  final Locale locale;
  final bool isLtr;
  final List<Language> languages;
  final int selectedIndex;
  final LanguageChangeStatus changeStatus;

  LanguageState({
    Locale? locale,
    this.isLtr = true,
    this.languages = const [],
    this.selectedIndex = 0,
    this.changeStatus = LanguageChangeStatus.none,
  }) : locale =
           locale ??
           Locale(
             AppConstants.languages[0].languageCode!,
             AppConstants.languages[0].countryCode,
           );

  LanguageState copyWith({
    Locale? locale,
    bool? isLtr,
    List<Language>? languages,
    int? selectedIndex,
    LanguageChangeStatus? changeStatus,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
      isLtr: isLtr ?? this.isLtr,
      languages: languages ?? this.languages,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      changeStatus: changeStatus ?? this.changeStatus,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    isLtr,
    languages,
    selectedIndex,
    changeStatus,
  ];
}
