import 'dart:io';

void forceAddImports(String path) {
  var file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  if (!content.contains('package:flutter_bloc/flutter_bloc.dart')) {
    content = content.replaceFirst("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
    file.writeAsStringSync(content);
  }
}

void main() {
  forceAddImports('lib/features/cart/widgets/not_available_bottom_sheet_widget.dart');
  forceAddImports('lib/features/cart/widgets/cart_item_widget.dart');
  forceAddImports('lib/features/cart/widgets/web_cart_items_widget.dart');
  forceAddImports('lib/features/cart/widgets/web_suggested_item_view_widget.dart');
  forceAddImports('lib/features/item/widgets/details_web_view_widget.dart');
  
  // also fix SetCurrentIndexEvent in web_suggested_item_view_widget.dart
  var file2 = File('lib/features/cart/widgets/web_suggested_item_view_widget.dart');
  var content2 = file2.readAsStringSync();
  content2 = content2.replaceAll('getIt<CartBloc>().add(SetCurrentIndexEvent(index, true),', 'getIt<CartBloc>().add(SetCurrentIndexEvent(index, true)),');
  file2.writeAsStringSync(content2);
  
  // wait! SetCurrentIndexEvent doesn't exist in CartEvent! It was CartController's setCurrentIndex.
  // We can just use the index directly or add it to CartEvent if needed.
  // Actually, I should check if SetCurrentIndexEvent exists.
}
