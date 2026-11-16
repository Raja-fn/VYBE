/// Turns what someone typed into an E.164 number for the launch country,
/// or null when it is not a valid number.
///
/// Accepts spaces, dashes, a leading 0, and the country code with or without
/// "+": "98765 43210", "098765-43210", "+91 98765 43210", "919876543210".
String? normalizePhoneNumber(String raw, {required String countryCode, required int nationalLength}) {
  final countryDigits = countryCode.replaceAll('+', '');
  var digits = raw.replaceAll(RegExp(r'[\s\-()]'), '');
  if (!RegExp(r'^\+?\d+$').hasMatch(digits)) return null;
  digits = digits.replaceAll('+', '');

  if (digits.length == nationalLength + countryDigits.length && digits.startsWith(countryDigits)) {
    digits = digits.substring(countryDigits.length);
  } else if (digits.length == nationalLength + 1 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.length != nationalLength || digits.startsWith('0')) return null;
  return '+$countryDigits$digits';
}

/// "+919876543210" -> "+91 98765 43210" for display.
String formatPhoneNumber(String e164, {required String countryCode}) {
  if (!e164.startsWith(countryCode)) return e164;
  final national = e164.substring(countryCode.length);
  if (national.length != 10) return '$countryCode $national';
  return '$countryCode ${national.substring(0, 5)} ${national.substring(5)}';
}

/// One-time codes are [length] digits (`otpLength` in AppConfig).
bool isValidOtp(String code, {required int length}) => RegExp('^\\d{$length}\$').hasMatch(code.trim());
