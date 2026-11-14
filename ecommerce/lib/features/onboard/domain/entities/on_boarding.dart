import 'package:equatable/equatable.dart';

/// Pure business entity for a single onboarding slide.
///
/// No Flutter, no data-layer imports (rule 1). The slides are static,
/// localized content (not an API payload) built in the data layer.
class OnBoarding extends Equatable {
  final String imageUrl;
  final String title;
  final String description;

  const OnBoarding({
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [imageUrl, title, description];
}
