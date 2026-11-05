import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/flash_sale/data/models/flash_sale_model.dart';
import 'package:ecommerce/features/flash_sale/data/models/product_flash_sale.dart';

abstract class FlashSaleRepository {
  Future<Either<Failure, FlashSaleModel>> getFlashSale();
  Future<Either<Failure, ProductFlashSale>> getFlashSaleWithId(
    int id,
    int offset,
  );
}
