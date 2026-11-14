import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/loyalty/domain/repositories/loyalty_repository.dart';

class ConvertPointToWalletUseCase
    implements UseCase<Unit, ConvertPointToWalletParams> {
  final LoyaltyRepository repository;

  ConvertPointToWalletUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ConvertPointToWalletParams params) {
    return repository.pointToWallet(params.point);
  }
}

class ConvertPointToWalletParams extends Equatable {
  final int point;

  const ConvertPointToWalletParams(this.point);

  @override
  List<Object?> get props => [point];
}
