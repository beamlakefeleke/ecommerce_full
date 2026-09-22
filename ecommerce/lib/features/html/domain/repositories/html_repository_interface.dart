import 'package:ecommerce/interfaces/repository_interface.dart';
import 'package:ecommerce/util/html_type.dart';

abstract class HtmlRepositoryInterface extends RepositoryInterface {
  Future<dynamic> getHtmlText(HtmlType htmlType);
}