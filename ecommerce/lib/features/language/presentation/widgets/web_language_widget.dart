import 'package:ecommerce/features/language/domain/entities/language.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_event.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class WebLanguageWidget extends StatelessWidget {
  final Language languageModel;
  final int index;
  final bool isSelected;
  const WebLanguageWidget({
    super.key,
    required this.languageModel,
    required this.index,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<LanguageBloc>().add(
          LanguageChanged(
            Locale(
              AppConstants.languages[index].languageCode!,
              AppConstants.languages[index].countryCode,
            ),
          ),
        );
        context.read<LanguageBloc>().add(LanguageIndexSelected(index));
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 59,
                    width: 59,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                      border: Border.all(
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      languageModel.imageUrl!,
                      width: 26,
                      height: 26,
                      color:
                          languageModel.languageCode == 'en' ||
                              languageModel.languageCode == 'ar' ||
                              languageModel.languageCode == 'es'
                          ? Theme.of(context).textTheme.bodyLarge!.color
                          : null,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeLarge),
                  Text(languageModel.languageName!, style: robotoRegular),
                ],
              ),
            ),

            isSelected
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
