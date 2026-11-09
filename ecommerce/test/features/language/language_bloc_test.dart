import 'dart:ui';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce/features/language/domain/repositories/language_repository.dart';
import 'package:ecommerce/features/language/domain/usecases/save_language_usecase.dart';
import 'package:ecommerce/features/language/domain/usecases/update_language_header_usecase.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_event.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_state.dart';

class MockLanguageRepository extends Mock implements LanguageRepository {}

class MockSaveLanguageUseCase extends Mock implements SaveLanguageUseCase {}

class MockUpdateLanguageHeaderUseCase extends Mock
    implements UpdateLanguageHeaderUseCase {}

void main() {
  late MockLanguageRepository repository;
  late MockSaveLanguageUseCase saveLanguage;
  late MockUpdateLanguageHeaderUseCase updateHeader;

  const english = Locale('en', 'US');
  const arabic = Locale('ar', 'SA');

  setUpAll(() {
    registerFallbackValue(const SaveLanguageParams(english));
    registerFallbackValue(const UpdateLanguageHeaderParams(locale: english));
  });

  setUp(() {
    repository = MockLanguageRepository();
    saveLanguage = MockSaveLanguageUseCase();
    updateHeader = MockUpdateLanguageHeaderUseCase();
  });

  LanguageBloc build() => LanguageBloc(
    repository: repository,
    saveLanguage: saveLanguage,
    updateHeader: updateHeader,
    currentModuleId: () => 1,
  );

  group('LanguageInitialized', () {
    blocTest<LanguageBloc, LanguageState>(
      'loads the saved locale, text direction and language list',
      setUp: () {
        when(() => repository.getSavedLocale()).thenReturn(arabic);
      },
      build: build,
      act: (bloc) => bloc.add(const LanguageInitialized()),
      verify: (_) {
        verify(() => repository.getSavedLocale()).called(1);
      },
      expect: () => [
        isA<LanguageState>()
            .having((s) => s.locale, 'locale', arabic)
            .having((s) => s.isLtr, 'isLtr', false)
            .having((s) => s.languages.isNotEmpty, 'has languages', true),
      ],
    );
  });

  group('LanguageChanged', () {
    blocTest<LanguageBloc, LanguageState>(
      'persists, updates the header, and emits an applied one-shot',
      setUp: () {
        when(() => repository.getSavedLocale()).thenReturn(english);
        when(
          () => updateHeader(any()),
        ).thenAnswer((_) async => const Right(unit));
        when(
          () => saveLanguage(any()),
        ).thenAnswer((_) async => const Right(unit));
      },
      build: build,
      act: (bloc) => bloc.add(const LanguageChanged(arabic)),
      verify: (_) {
        verify(() => updateHeader(any())).called(1);
        verify(() => saveLanguage(any())).called(1);
      },
      expect: () => [
        isA<LanguageState>()
            .having((s) => s.locale, 'locale', arabic)
            .having((s) => s.isLtr, 'isLtr', false)
            .having(
              (s) => s.changeStatus,
              'changeStatus',
              LanguageChangeStatus.applied,
            ),
        isA<LanguageState>().having(
          (s) => s.changeStatus,
          'changeStatus',
          LanguageChangeStatus.none,
        ),
      ],
    );
  });

  group('LanguageSearched', () {
    blocTest<LanguageBloc, LanguageState>(
      'filters the list to a non-matching query to empty',
      build: build,
      act: (bloc) => bloc.add(const LanguageSearched('zzzz')),
      expect: () => [
        isA<LanguageState>()
            .having((s) => s.languages, 'languages', isEmpty)
            .having((s) => s.selectedIndex, 'selectedIndex', -1),
      ],
    );
  });
}
