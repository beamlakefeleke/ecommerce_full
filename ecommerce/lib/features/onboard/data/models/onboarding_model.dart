import 'package:ecommerce/features/onboard/domain/entities/on_boarding.dart';

/// Data-layer model for an onboarding slide. Extends the pure [OnBoarding]
/// entity and adds `toEntity()`. (The slides are static/local, so there is no
/// `fromJson`/`toJson`.)
class OnBoardingModel extends OnBoarding {
  const OnBoardingModel({
    required super.imageUrl,
    required super.title,
    required super.description,
  });

  OnBoarding toEntity() =>
      OnBoarding(imageUrl: imageUrl, title: title, description: description);
}
