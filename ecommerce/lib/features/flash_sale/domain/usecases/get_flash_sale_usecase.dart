import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/flash_sale/data/models/flash_sale_model.dart';
import 'package:ecommerce/features/flash_sale/domain/repositories/flash_sale_repository.dart';

class GetFlashSaleUseCase implements UseCase<FlashSaleModel, NoParams> {
  final FlashSaleRepository repository;

  GetFlashSaleUseCase(this.repository);

  @override
  Future<Either<Failure, FlashSaleModel>> call(NoParams params) {
    return repository.getFlashSale();
  }
}
