import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/util/html_type.dart';

abstract class HtmlRepository {
  Future<Either<Failure, String>> getHtmlText(HtmlType htmlType);
}
