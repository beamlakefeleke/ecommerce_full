import 'package:get/get.dart';
import 'package:ecommerce/util/html_type.dart';

abstract class HtmlServiceInterface{
  Future<Response> getHtmlText(HtmlType htmlType);
}