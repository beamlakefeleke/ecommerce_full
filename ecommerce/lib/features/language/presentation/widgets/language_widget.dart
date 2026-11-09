import 'package:ecommerce/features/language/domain/entities/language.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_event.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageWidget extends StatelessWidget {
  final Language languageModel;
  final int index;
  final bool isSelected;
  const LanguageWidget({
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
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 65,
                    width: 65,
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
                      width: 36,
                      height: 36,
                      color:
                          languageModel.languageCode == 'en' ||
                              languageModel.languageCode == 'ar' ||
                              languageModel.languageCode == 'es' ||
                              languageModel.languageCode == 'bn'
                          ? Theme.of(context).textTheme.bodyLarge!.color
                          : null,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
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
