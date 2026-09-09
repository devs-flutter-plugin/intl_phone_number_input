# intl_phone_number_input

Maintained Flutter package for international phone number input, based on the original [`natintosh/intl_phone_number_input`](https://github.com/natintosh/intl_phone_number_input) project.

This fork targets the current standalone Flutter Material UI package and modern Dart/Flutter toolchain.

## Requirements

- Flutter 3.47.0 or newer
- Dart 3.13.0 or newer
- `material_ui` 1.2.x

## What changed in 0.8.0

- Migrated all package/example/test UI imports from `package:flutter/material.dart` to `package:material_ui/material_ui.dart`.
- Updated libphonenumber implementation to `dlibphonenumber ^1.1.71`.
- Updated `equatable` to `^2.1.0` and `flutter_lints` to `^6.0.0`.
- Replaced bundled PNG country flags and the generated legacy country table with `sealed_countries ^3.3.0` metadata and Unicode emoji flags.
- Kept the primary public API: `InternationalPhoneNumberInput`, `PhoneNumber`, `SelectorConfig`, `PhoneInputSelectorType`, `PhoneNumberType`, and `CountryComparator`.
- Added a self-hosted GitHub Actions validation pipeline.

### Breaking change: flags

PNG flag assets are no longer bundled. `SelectorConfig.useEmoji` now defaults to `true`. Setting it to `false` hides the flag instead of switching back to PNG assets.

## Installation

```yaml
dependencies:
  intl_phone_number_input:
    git:
      url: https://github.com/devs-flutter-plugin/intl_phone_number_input.git
      ref: main
```

For production projects, prefer a released Git tag instead of `main`.

## Basic usage

```dart
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:material_ui/material_ui.dart';

class PhoneFieldExample extends StatefulWidget {
  const PhoneFieldExample({super.key});

  @override
  State<PhoneFieldExample> createState() => _PhoneFieldExampleState();
}

class _PhoneFieldExampleState extends State<PhoneFieldExample> {
  PhoneNumber? value;

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      initialValue: PhoneNumber(isoCode: 'BR'),
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
      ),
      onInputChanged: (number) {
        setState(() => value = number);
      },
      onInputValidated: (valid) {
        debugPrint('valid: $valid');
      },
    );
  }
}
```

## Country selector

The selector supports the same three presentation modes:

```dart
const SelectorConfig(
  selectorType: PhoneInputSelectorType.DROPDOWN,
);

const SelectorConfig(
  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
);

const SelectorConfig(
  selectorType: PhoneInputSelectorType.DIALOG,
);
```

Restrict countries with ISO alpha-2 codes:

```dart
InternationalPhoneNumberInput(
  countries: const ['BR', 'US', 'PT'],
  initialValue: PhoneNumber(isoCode: 'BR'),
  onInputChanged: (number) {},
);
```

## Phone number helpers

```dart
final number = await PhoneNumber.getRegionInfoFromPhoneNumber(
  '+55 11 98765-4321',
  'BR',
);

final national = await PhoneNumber.getParsableNumber(number);
final type = await PhoneNumber.getPhoneNumberType(
  number.phoneNumber!,
  number.isoCode!,
);
```

## Material UI migration

This package itself no longer imports `package:flutter/material.dart`. Apps already migrated to standalone Material UI can use it directly.

If the rest of an application still contains legacy dependencies importing `package:flutter/material.dart`, follow Flutter's `material_ui` compatibility guidance and bridge only the legacy subtree where necessary.

## License and attribution

MIT licensed. The original copyright notice is retained in `LICENSE`.
