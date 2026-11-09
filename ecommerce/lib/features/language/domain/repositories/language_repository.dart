import 'dart:ui';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';

/// Abstract contract for the language feature. Implemented in the data layer.
/// Every method returns `Either<Failure, T>` — no throwing across the boundary.
abstract class LanguageRepository {
  /// The persisted locale, or the app's default locale when none is saved.
  Locale getSavedLocale();

  /// Persist the chosen [locale] to local storage.
  Future<Either<Failure, Unit>> saveLanguage(Locale locale);

  /// Re-set the `ApiClient` localization header for [locale] (and the current
  /// module), reading the saved address from local storage. Called when the
  /// user switches language so subsequent requests carry the new locale.
  Future<Either<Failure, Unit>> updateHeader(Locale locale, int? moduleId);
}
