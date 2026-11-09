import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/language/domain/repositories/language_repository.dart';

class SaveLanguageUseCase implements UseCase<Unit, SaveLanguageParams> {
  final LanguageRepository repository;

  SaveLanguageUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SaveLanguageParams params) {
    return repository.saveLanguage(params.locale);
  }
}

class SaveLanguageParams extends Equatable {
  final Locale locale;

  const SaveLanguageParams(this.locale);

  @override
  List<Object?> get props => [locale];
}
