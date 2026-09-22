const fs = require('fs');
const file = 'lib/features/cart/screens/cart_screen.dart';
let content = fs.readFileSync(file, 'utf8');

const classIdx = content.indexOf('class CartScreen extends StatefulWidget');
let bottomPart = content.substring(classIdx);

// Clean up duplicate initCall
bottomPart = bottomPart.replace(/  void initCall\(\) {[\s\S]*?  }/g, '');
bottomPart = bottomPart.replace(/    if\(Get\.find<CartController>\(\)\.cartList\.isNotEmpty\){\s*if \(kDebugMode\) {[\s\S]*?    }/g, '');

const finalFile = `import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/cart/widgets/not_available_bottom_sheet_widget.dart';
import 'package:ecommerce/features/coupon/controllers/coupon_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/controllers/store_controller.dart';
import 'package:ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/item_widget.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';
import 'package:ecommerce/common/widgets/web_constrained_box.dart';
import 'package:ecommerce/common/widgets/web_page_title_widget.dart';
import 'package:ecommerce/features/cart/widgets/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/cart/widgets/web_cart_items_widget.dart';
import 'package:ecommerce/features/cart/widgets/web_suggested_item_view_widget.dart';
import 'package:ecommerce/features/home/screens/home_screen.dart';
import 'package:ecommerce/features/store/screens/store_screen.dart';

` + bottomPart;

fs.writeFileSync(file, finalFile);
