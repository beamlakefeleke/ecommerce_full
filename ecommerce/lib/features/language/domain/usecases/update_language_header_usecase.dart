import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/language/domain/repositories/language_repository.dart';

class UpdateLanguageHeaderUseCase
    implements UseCase<Unit, UpdateLanguageHeaderParams> {
  final LanguageRepository repository;

  UpdateLanguageHeaderUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateLanguageHeaderParams params) {
    return repository.updateHeader(params.locale, params.moduleId);
  }
}

class UpdateLanguageHeaderParams extends Equatable {
  final Locale locale;
  final int? moduleId;

  const UpdateLanguageHeaderParams({required this.locale, this.moduleId});

  @override
  List<Object?> get props => [locale, moduleId];
}
