import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/util/styles.dart';

class PriceConverter {
  static String convertPrice(
    double? price, {
    double? discount,
    String? discountType,
    bool forDM = false,
    bool isFoodVariation = false,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount' && !isFoodVariation) {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    bool isRightSide =
        getIt<SplashBloc>().state.configModel!.currencySymbolDirection ==
        'right';
    return '${isRightSide ? '' : '${getIt<SplashBloc>().state.configModel!.currencySymbol!} '}'
        '${toFixed(price!).toStringAsFixed(forDM ? 0 : getIt<SplashBloc>().state.configModel!.digitAfterDecimalPoint!).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        '${isRightSide ? ' ${getIt<SplashBloc>().state.configModel!.currencySymbol!}' : ''}';
  }

  static Widget convertAnimationPrice(
    double? price, {
    double? discount,
    String? discountType,
    bool forDM = false,
    TextStyle? textStyle,
  }) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    bool isRightSide =
        getIt<SplashBloc>().state.configModel!.currencySymbolDirection ==
        'right';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        value: toFixed(price!),
        textStyle: textStyle ?? robotoMedium,
        fractionDigits: forDM
            ? 0
            : getIt<SplashBloc>().state.configModel!.digitAfterDecimalPoint!,
        prefix: isRightSide
            ? ''
            : getIt<SplashBloc>().state.configModel!.currencySymbol!,
        suffix: isRightSide
            ? getIt<SplashBloc>().state.configModel!.currencySymbol!
            : '',
      ),
    );
  }

  static double? convertWithDiscount(
    double? price,
    double? discount,
    String? discountType, {
    bool isFoodVariation = false,
  }) {
    if (discountType == 'amount' && !isFoodVariation) {
      price = price! - discount!;
    } else if (discountType == 'percent') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static double calculation(
    double amount,
    double? discount,
    String type,
    int quantity,
  ) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount! * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount! / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
    String price,
    String discount,
    String discountType,
  ) {
    return '$discount${discountType == 'percent' ? '%' : getIt<SplashBloc>().state.configModel!.currencySymbol} OFF';
  }

  static double toFixed(double val) {
    num mod = power(
      10,
      getIt<SplashBloc>().state.configModel!.digitAfterDecimalPoint!,
    );
    return (((val * mod).toPrecision(
          getIt<SplashBloc>().state.configModel!.digitAfterDecimalPoint!,
        )).floor().toDouble() /
        mod);
  }

  static int power(int x, int n) {
    int retval = 1;
    for (int i = 0; i < n; i++) {
      retval *= x;
    }
    return retval;
  }
}
