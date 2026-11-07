import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/html/domain/repositories/html_repository.dart';
import 'package:ecommerce/util/html_type.dart';

class GetHtmlTextParams extends Equatable {
  final HtmlType htmlType;

  const GetHtmlTextParams(this.htmlType);

  @override
  List<Object?> get props => [htmlType];
}

class GetHtmlTextUseCase implements UseCase<String, GetHtmlTextParams> {
  final HtmlRepository repository;

  GetHtmlTextUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(GetHtmlTextParams params) {
    return repository.getHtmlText(params.htmlType);
  }
}
