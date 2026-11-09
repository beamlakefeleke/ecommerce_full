import 'dart:ui';
import 'package:equatable/equatable.dart';

sealed class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

/// Load the persisted language and populate the selectable list. Dispatched
/// once when the app-wide bloc is created.
class LanguageInitialized extends LanguageEvent {
  const LanguageInitialized();
}

/// Persist and apply [locale] as the active app language. The resulting locale
/// change is surfaced in the state so `main.dart` can sync `Get.updateLocale`
/// and reload zone/landing data via a `BlocListener`.
class LanguageChanged extends LanguageEvent {
  final Locale locale;

  const LanguageChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}

/// Highlight the language at [index] in the grid without applying it yet.
class LanguageIndexSelected extends LanguageEvent {
  final int index;

  const LanguageIndexSelected(this.index);

  @override
  List<Object?> get props => [index];
}

/// Filter the selectable language list by [query].
class LanguageSearched extends LanguageEvent {
  final String query;

  const LanguageSearched(this.query);

  @override
  List<Object?> get props => [query];
}
