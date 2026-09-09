import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

void main() {
  group('PhoneNumber', () {
    test('resolves ISO code from international prefix', () {
      expect(PhoneNumber.getISO2CodeByPrefix('+55'), 'BR');
    });

    test('parses and formats an E.164 number', () async {
      final number = await PhoneNumber.getRegionInfoFromPhoneNumber(
        '+1 415 555 2671',
        'US',
      );

      expect(number.isoCode, 'US');
      expect(number.dialCode, '+1');
      expect(number.phoneNumber, '+14155552671');

      final national = await PhoneNumber.getParsableNumber(number);
      expect(national, contains('415'));
    });

    test('maps libphonenumber number type', () async {
      final type = await PhoneNumber.getPhoneNumberType(
        '+1 415 555 2671',
        'US',
      );

      expect(
        type,
        anyOf(
          PhoneNumberType.FIXED_LINE,
          PhoneNumberType.MOBILE,
          PhoneNumberType.FIXED_LINE_OR_MOBILE,
        ),
      );
    });
  });
}
