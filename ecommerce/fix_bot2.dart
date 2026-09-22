import 'dart:io';

void main() {
  // 1. cart_item_widget.dart
  var file1 = File('lib/features/cart/widgets/cart_item_widget.dart');
  var content1 = file1.readAsStringSync();
  content1 = content1.replaceAll('CartModel.fromJson(cart.toJson())', 'cart as CartModel');
  file1.writeAsStringSync(content1);

  // 2. details_web_view_widget.dart
  var file2 = File('lib/features/item/widgets/details_web_view_widget.dart');
  var content2 = file2.readAsStringSync();
  content2 = content2.replaceAll('cartList: [CartModel.fromJson(cartModel!.toJson())]', 'cartList: [cartModel as CartModel]');
  file2.writeAsStringSync(content2);

  // 3. item_bottom_sheet.dart syntax
  var file3 = File('lib/common/widgets/item_bottom_sheet.dart');
  var content3 = file3.readAsStringSync();
  // Restore the deleted InkWell
  content3 = content3.replaceAll(
    "widget.item!.name!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),\n                                maxLines: 2, overflow: TextOverflow.ellipsis,\n                                },",
    "widget.item!.name!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),\n                                maxLines: 2, overflow: TextOverflow.ellipsis,\n                              ),\n                              InkWell(\n                                onTap: () {\n                                  if(widget.inStorePage) {\n                                    Get.back();\n                                  }else {\n                                    Get.back();\n                                    getIt<CartBloc>().add(ForcefullySetModuleEvent(widget.item!.moduleId!));\n                                    Get.toNamed(\n                                      RouteHelper.getStoreRoute(id: widget.item!.storeId, page: 'item'),\n                                    );\n                                    Get.offNamed(RouteHelper.getStoreRoute(id: widget.item!.storeId, page: 'item'));\n                                  }\n                                },"
  );
  
  // also fix the syntax error of extra parentheses at the end that I saw in the previous log:
  // "error - Expected to find ')' - lib\common\widgets\item_bottom_sheet.dart:209:107"
  // Wait, I fixed it in the replacement above by restoring the whole block correctly!
  file3.writeAsStringSync(content3);
}
