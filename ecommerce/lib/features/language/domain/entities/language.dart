import 'package:equatable/equatable.dart';

/// Pure business object describing a selectable app language.
///
/// No JSON, no Flutter, no transport-only fields (rule 7). The serializable
/// representation lives in `data/models/language_model.dart`.
class Language extends Equatable {
  final String? imageUrl;
  final String? languageName;
  final String? languageCode;
  final String? countryCode;

  const Language({
    this.imageUrl,
    this.languageName,
    this.languageCode,
    this.countryCode,
  });

  @override
  List<Object?> get props => [
    imageUrl,
    languageName,
    languageCode,
    countryCode,
  ];
}
