import 'package:ecommerce/features/language/domain/entities/language.dart';

/// The single serializable representation of a [Language] (rule 7).
///
/// `AppConstants.languages` constructs these directly, so the constructor
/// signature mirrors the legacy `LanguageModel` to keep that call site intact.
class LanguageModel extends Language {
  const LanguageModel({
    super.imageUrl,
    super.languageName,
    super.languageCode,
    super.countryCode,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      imageUrl: json['image_url'],
      languageName: json['language_name'],
      languageCode: json['language_code'],
      countryCode: json['country_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'language_name': languageName,
      'language_code': languageCode,
      'country_code': countryCode,
    };
  }

  Language toEntity() => Language(
    imageUrl: imageUrl,
    languageName: languageName,
    languageCode: languageCode,
    countryCode: countryCode,
  );

  factory LanguageModel.fromEntity(Language entity) => LanguageModel(
    imageUrl: entity.imageUrl,
    languageName: entity.languageName,
    languageCode: entity.languageCode,
    countryCode: entity.countryCode,
  );
}
