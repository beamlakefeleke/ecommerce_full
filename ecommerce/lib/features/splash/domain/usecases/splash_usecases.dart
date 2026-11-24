import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/splash/domain/repositories/splash_repository.dart';

class GetConfigDataUseCase
    implements UseCase<SplashConfigResult, NoParams> {
  final SplashRepository repository;
  GetConfigDataUseCase(this.repository);

  @override
  Future<Either<Failure, SplashConfigResult>> call(NoParams params) =>
      repository.getConfigData();
}

class GetModulesUseCase
    implements UseCase<List<ModuleModel>, Map<String, String>?> {
  final SplashRepository repository;
  GetModulesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ModuleModel>>> call(
    Map<String, String>? headers,
  ) => repository.getModules(headers: headers);
}

class SubscribeEmailUseCase implements UseCase<ResponseModel, String> {
  final SplashRepository repository;
  SubscribeEmailUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseModel>> call(String email) async {
    final result = await repository.subscribeEmail(email);
    return Right(result);
  }
}
