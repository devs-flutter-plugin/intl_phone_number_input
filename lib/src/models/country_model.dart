/// Country metadata used by the phone input selector.
class Country {
  const Country({
    required this.name,
    required this.alpha2Code,
    required this.alpha3Code,
    required this.dialCode,
    required this.emoji,
    this.nameTranslations,
  });

  /// Common English country name.
  final String name;

  /// ISO 3166-1 alpha-2 code.
  final String alpha2Code;

  /// ISO 3166-1 alpha-3 code.
  final String alpha3Code;

  /// International dial code including the leading plus sign.
  final String dialCode;

  /// Unicode flag emoji.
  final String emoji;

  /// Optional translated country names retained for API compatibility.
  final Map<String, String>? nameTranslations;

  /// Legacy asset path retained for source compatibility.
  ///
  /// PNG flags were removed in 0.8.0. Use [emoji] instead.
  @Deprecated('PNG flag assets were removed in 0.8.0. Use emoji instead.')
  String get flagUri => '';

  @override
  bool operator ==(Object other) {
    return other is Country &&
        other.alpha2Code == alpha2Code &&
        other.alpha3Code == alpha3Code &&
        other.dialCode == dialCode;
  }

  @override
  int get hashCode => Object.hash(alpha2Code, alpha3Code, dialCode);

  @override
  String toString() =>
      'Country(name: $name, alpha2: $alpha2Code, alpha3: $alpha3Code, dialCode: $dialCode)';
}
