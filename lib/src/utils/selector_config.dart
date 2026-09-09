// ignore_for_file: constant_identifier_names

import '../models/country_model.dart';

/// Country selector presentation mode.
enum PhoneInputSelectorType {
  DROPDOWN,
  BOTTOM_SHEET,
  DIALOG,
}

/// Function signature used to customize country ordering.
typedef CountryComparator = int Function(Country a, Country b);

/// Configuration for the country selector.
class SelectorConfig {
  const SelectorConfig({
    this.selectorType = PhoneInputSelectorType.DROPDOWN,
    this.showFlags = true,
    this.useEmoji = true,
    this.countryComparator,
    this.setSelectorButtonAsPrefixIcon = false,
    this.leadingPadding,
    this.trailingSpace = true,
    this.useBottomSheetSafeArea = false,
    this.showInputFlag,
  });

  final PhoneInputSelectorType selectorType;
  final bool showFlags;

  /// Kept for source compatibility.
  ///
  /// From 0.8.0 onward flags are Unicode emoji and PNG assets are no longer
  /// bundled. Setting this to false hides the flag rather than selecting PNGs.
  final bool useEmoji;

  final CountryComparator? countryComparator;
  final bool setSelectorButtonAsPrefixIcon;
  final double? leadingPadding;
  final bool trailingSpace;
  final bool useBottomSheetSafeArea;
  final bool? showInputFlag;
}
