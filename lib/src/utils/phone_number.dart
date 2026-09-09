// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:dlibphonenumber/dlibphonenumber.dart' as dlib;
import 'package:equatable/equatable.dart';

/// Types of phone numbers as defined by libphonenumber.
enum PhoneNumberType {
  FIXED_LINE,
  MOBILE,
  FIXED_LINE_OR_MOBILE,
  TOLL_FREE,
  PREMIUM_RATE,
  SHARED_COST,
  VOIP,
  PERSONAL_NUMBER,
  PAGER,
  UAN,
  VOICEMAIL,
  UNKNOWN,
}

/// Represents a phone number and its country metadata.
class PhoneNumber extends Equatable {
  PhoneNumber({
    this.phoneNumber,
    this.dialCode,
    this.isoCode,
  }) : _hash = 1000 + Random().nextInt(98999);

  final String? phoneNumber;
  final String? dialCode;
  final String? isoCode;
  final int _hash;

  /// Compatibility hash used by the original package to detect new instances.
  int get hash => _hash;

  @override
  List<Object?> get props => [phoneNumber, isoCode, dialCode];

  @override
  String toString() =>
      'PhoneNumber(phoneNumber: $phoneNumber, dialCode: $dialCode, isoCode: $isoCode)';

  /// Parses [phoneNumber] and resolves its region information.
  static Future<PhoneNumber> getRegionInfoFromPhoneNumber(
    String phoneNumber, [
    String isoCode = '',
  ]) async {
    if (phoneNumber.trim().isEmpty) {
      throw ArgumentError.value(phoneNumber, 'phoneNumber', 'Cannot be empty.');
    }

    final util = dlib.PhoneNumberUtil.instance;
    final regionHint = isoCode.trim().toUpperCase();
    final parsed = util.parse(phoneNumber, regionHint.isEmpty ? null : regionHint);
    final resolvedRegion = util.getRegionCodeForNumber(parsed);

    return PhoneNumber(
      phoneNumber: util.format(parsed, dlib.PhoneNumberFormat.e164),
      dialCode: '+${parsed.countryCode}',
      isoCode: resolvedRegion ?? (regionHint.isEmpty ? null : regionHint),
    );
  }

  /// Returns the national formatted representation without the country code.
  static Future<String> getParsableNumber(PhoneNumber phoneNumber) async {
    final value = phoneNumber.phoneNumber;
    final iso = phoneNumber.isoCode;
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    if (iso == null || iso.trim().isEmpty) {
      throw Exception('ISO Code is "$iso"');
    }

    final util = dlib.PhoneNumberUtil.instance;
    final parsed = util.parse(value, iso.toUpperCase());
    return util.format(parsed, dlib.PhoneNumberFormat.national);
  }

  /// Returns [phoneNumber] without [dialCode].
  String parseNumber() {
    final value = phoneNumber ?? '';
    final prefix = dialCode ?? '';
    if (prefix.isEmpty) {
      return value;
    }
    return value.replaceFirst(RegExp('^${RegExp.escape(prefix)}'), '');
  }

  /// Returns the primary ISO alpha-2 region for a country calling prefix.
  static String? getISO2CodeByPrefix(String prefix) {
    final digits = prefix.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return null;
    }

    final countryCode = int.tryParse(digits);
    if (countryCode == null) {
      return null;
    }

    final region =
        dlib.PhoneNumberUtil.instance.getRegionCodeForCountryCode(countryCode);
    return region == 'ZZ' || region == '001' ? null : region;
  }

  /// Returns the libphonenumber type for [phoneNumber].
  static Future<PhoneNumberType> getPhoneNumberType(
    String phoneNumber,
    String isoCode,
  ) async {
    final util = dlib.PhoneNumberUtil.instance;
    final parsed = util.parse(phoneNumber, isoCode.toUpperCase());
    final type = util.getNumberType(parsed);

    return switch (type) {
      dlib.PhoneNumberType.fixedLine => PhoneNumberType.FIXED_LINE,
      dlib.PhoneNumberType.mobile => PhoneNumberType.MOBILE,
      dlib.PhoneNumberType.fixedLineOrMobile =>
        PhoneNumberType.FIXED_LINE_OR_MOBILE,
      dlib.PhoneNumberType.tollFree => PhoneNumberType.TOLL_FREE,
      dlib.PhoneNumberType.premiumRate => PhoneNumberType.PREMIUM_RATE,
      dlib.PhoneNumberType.sharedCost => PhoneNumberType.SHARED_COST,
      dlib.PhoneNumberType.voip => PhoneNumberType.VOIP,
      dlib.PhoneNumberType.personalNumber => PhoneNumberType.PERSONAL_NUMBER,
      dlib.PhoneNumberType.pager => PhoneNumberType.PAGER,
      dlib.PhoneNumberType.uan => PhoneNumberType.UAN,
      dlib.PhoneNumberType.voicemail => PhoneNumberType.VOICEMAIL,
      dlib.PhoneNumberType.unknown => PhoneNumberType.UNKNOWN,
    };
  }
}
