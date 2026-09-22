import 'dart:io';

void replaceInFile(String path) {
  final file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Replace CartModel with Cart
  content = content.replaceAll('CartModel', 'Cart');
  // Need to import Cart entity if not present
  if (!content.contains('package:ecommerce/features/cart/domain/entities/cart.dart')) {
    content = content.replaceAll(
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/material.dart';\nimport 'package:ecommerce/features/cart/domain/entities/cart.dart';"
    );
  }

  file.writeAsStringSync(content);
}

void main() {
  replaceInFile('lib/features/cart/widgets/web_cart_items_widget.dart');
  replaceInFile('lib/features/cart/widgets/cart_item_widget.dart');
  replaceInFile('lib/features/cart/widgets/web_suggested_item_view_widget.dart');
  print('Replaced CartModel with Cart in child widgets.');
}
