## [0.8.1]

- Fix `Country` type collision between the package model and `sealed_countries` in `input_widget.dart`.
- Restore correct typing for country properties, comparators, popup menu entries, and compiler inference.

## [0.8.0]

- Migrated from `package:flutter/material.dart` to the standalone `package:material_ui/material_ui.dart` package.
- Raised the minimum toolchain to Flutter 3.47 and Dart 3.13.
- Updated `dlibphonenumber` to 1.1.71, `equatable` to 2.1.0, and `flutter_lints` to 6.0.0.
- Removed bundled PNG flag assets and the generated legacy country table.
- Added `sealed_countries` 3.3.0 for ISO country metadata and emoji flags.
- Reworked country selector, validation, formatting, examples, tests, and CI for the modern Flutter toolchain.
- Exported `Country` explicitly because it is part of the public `CountryComparator` signature.

## Historical versions

Versions through 0.7.5 originated in `natintosh/intl_phone_number_input`. See the upstream changelog for the full historical release notes.
