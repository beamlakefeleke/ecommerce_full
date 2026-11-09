import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/language/domain/entities/language.dart';
import 'package:ecommerce/features/language/domain/repositories/language_repository.dart';
import 'package:ecommerce/features/language/domain/usecases/save_language_usecase.dart';
import 'package:ecommerce/features/language/domain/usecases/update_language_header_usecase.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_event.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_state.dart';
import 'package:ecommerce/util/app_constants.dart';

/// App-wide language/localization bloc. It owns the active [Locale], text
/// direction, and the selectable language list. Input is only via `add(Event)`
/// (no public methods). The "apply" side effects (Get.updateLocale, zone /
/// landing reload) live in `main.dart`'s `BlocListener`, not here.
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageRepository repository;
  final SaveLanguageUseCase saveLanguage;
  final UpdateLanguageHeaderUseCase updateHeader;

  /// Lazily resolves the current module id (config lives in the still-GetX
  /// splash feature) so the domain layer stays decoupled from SplashController.
  final int? Function() currentModuleId;

  LanguageBloc({
    required this.repository,
    required this.saveLanguage,
    required this.updateHeader,
    required this.currentModuleId,
  }) : super(LanguageState()) {
    on<LanguageInitialized>(_onInitialized);
    on<LanguageChanged>(_onChanged);
    on<LanguageIndexSelected>(_onIndexSelected);
    on<LanguageSearched>(_onSearched);
  }

  void _onInitialized(LanguageInitialized event, Emitter<LanguageState> emit) {
    final locale = repository.getSavedLocale();
    emit(
      state.copyWith(
        locale: locale,
        isLtr: locale.languageCode != 'ar',
        selectedIndex: _indexForLocale(locale),
        languages: List<Language>.from(AppConstants.languages),
        changeStatus: LanguageChangeStatus.none,
      ),
    );
  }

  Future<void> _onChanged(
    LanguageChanged event,
    Emitter<LanguageState> emit,
  ) async {
    await updateHeader(
      UpdateLanguageHeaderParams(
        locale: event.locale,
        moduleId: currentModuleId(),
      ),
    );
    await saveLanguage(SaveLanguageParams(event.locale));
    emit(
      state.copyWith(
        locale: event.locale,
        isLtr: event.locale.languageCode != 'ar',
        changeStatus: LanguageChangeStatus.applied,
      ),
    );
    // Reset the one-shot signal so a later identical change still triggers it.
    emit(state.copyWith(changeStatus: LanguageChangeStatus.none));
  }

  void _onIndexSelected(
    LanguageIndexSelected event,
    Emitter<LanguageState> emit,
  ) {
    emit(state.copyWith(selectedIndex: event.index));
  }

  void _onSearched(LanguageSearched event, Emitter<LanguageState> emit) {
    if (event.query.isEmpty) {
      emit(
        state.copyWith(languages: List<Language>.from(AppConstants.languages)),
      );
    } else {
      final filtered = AppConstants.languages
          .where(
            (l) =>
                l.languageName?.toLowerCase().contains(
                  event.query.toLowerCase(),
                ) ??
                false,
          )
          .toList();
      emit(state.copyWith(selectedIndex: -1, languages: filtered));
    }
  }

  int _indexForLocale(Locale locale) {
    for (int i = 0; i < AppConstants.languages.length; i++) {
      if (AppConstants.languages[i].languageCode == locale.languageCode) {
        return i;
      }
    }
    return 0;
  }
}
