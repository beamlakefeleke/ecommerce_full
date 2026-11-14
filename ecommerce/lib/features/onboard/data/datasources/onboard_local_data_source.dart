import 'package:get/get_utils/get_utils.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/onboard/data/models/onboarding_model.dart';
import 'package:ecommerce/util/images.dart';

/// Supplies the onboarding slides. The content is static and localized (not a
/// network payload), so it lives here in the data layer. Throws
/// [CacheException] if the static list can't be built.
abstract class OnboardLocalDataSource {
  List<OnBoardingModel> getOnBoardingList();
}

class OnboardLocalDataSourceImpl implements OnboardLocalDataSource {
  @override
  List<OnBoardingModel> getOnBoardingList() {
    try {
      return [
        OnBoardingModel(
          imageUrl: Images.onboard_1,
          title: 'on_boarding_1_title'.tr,
          description: 'on_boarding_1_description'.tr,
        ),
        OnBoardingModel(
          imageUrl: Images.onboard_2,
          title: 'on_boarding_2_title'.tr,
          description: 'on_boarding_2_description'.tr,
        ),
        OnBoardingModel(
          imageUrl: Images.onboard_3,
          title: 'on_boarding_3_title'.tr,
          description: 'on_boarding_3_description'.tr,
        ),
      ];
    } catch (e) {
      throw const CacheException('Onboarding data not found');
    }
  }
}
