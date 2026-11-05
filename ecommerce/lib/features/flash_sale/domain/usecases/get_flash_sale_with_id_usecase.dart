import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/flash_sale/data/models/product_flash_sale.dart';
import 'package:ecommerce/features/flash_sale/domain/repositories/flash_sale_repository.dart';

class FlashSaleWithIdParams extends Equatable {
  final int id;
  final int offset;

  const FlashSaleWithIdParams({required this.id, required this.offset});

  @override
  List<Object?> get props => [id, offset];
}

class GetFlashSaleWithIdUseCase
    implements UseCase<ProductFlashSale, FlashSaleWithIdParams> {
  final FlashSaleRepository repository;

  GetFlashSaleWithIdUseCase(this.repository);

  @override
  Future<Either<Failure, ProductFlashSale>> call(FlashSaleWithIdParams params) {
    return repository.getFlashSaleWithId(params.id, params.offset);
  }
}
