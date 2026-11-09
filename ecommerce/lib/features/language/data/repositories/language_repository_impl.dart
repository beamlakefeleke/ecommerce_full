import 'dart:ui';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/language/data/datasources/language_local_data_source.dart';
import 'package:ecommerce/features/language/domain/repositories/language_repository.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageLocalDataSource localDataSource;

  LanguageRepositoryImpl({required this.localDataSource});

  @override
  Locale getSavedLocale() => localDataSource.getSavedLocale();

  @override
  Future<Either<Failure, Unit>> saveLanguage(Locale locale) async {
    try {
      localDataSource.saveLanguage(locale);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateHeader(
    Locale locale,
    int? moduleId,
  ) async {
    try {
      localDataSource.updateHeader(locale, moduleId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
