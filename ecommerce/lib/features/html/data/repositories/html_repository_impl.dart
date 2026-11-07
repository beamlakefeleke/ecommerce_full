import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/html/data/datasources/html_remote_data_source.dart';
import 'package:ecommerce/features/html/domain/repositories/html_repository.dart';
import 'package:ecommerce/util/html_type.dart';

class HtmlRepositoryImpl implements HtmlRepository {
  final HtmlRemoteDataSource remoteDataSource;

  HtmlRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> getHtmlText(HtmlType htmlType) async {
    try {
      String htmlText = await remoteDataSource.getHtmlText(htmlType);
      // Open links in a new tab (ported from the legacy controller).
      if (htmlText.isNotEmpty) {
        htmlText = htmlText.replaceAll('href=', 'target="_blank" href=');
      }
      return Right(htmlText);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
