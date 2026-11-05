import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/flash_sale/data/datasources/flash_sale_remote_data_source.dart';
import 'package:ecommerce/features/flash_sale/data/models/flash_sale_model.dart';
import 'package:ecommerce/features/flash_sale/data/models/product_flash_sale.dart';
import 'package:ecommerce/features/flash_sale/domain/repositories/flash_sale_repository.dart';

class FlashSaleRepositoryImpl implements FlashSaleRepository {
  final FlashSaleRemoteDataSource remoteDataSource;

  FlashSaleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FlashSaleModel>> getFlashSale() async {
    try {
      return Right(await remoteDataSource.getFlashSale());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProductFlashSale>> getFlashSaleWithId(
    int id,
    int offset,
  ) async {
    try {
      return Right(await remoteDataSource.getFlashSaleWithId(id, offset));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
