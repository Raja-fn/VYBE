import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/backend/tables.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';

/// Someone the person trusts, who can be sent their location in one tap.
class TrustedContact {
  const TrustedContact({required this.name, required this.phoneE164});

  final String name;
  final String phoneE164;

  @override
  bool operator ==(Object other) => other is TrustedContact && other.name == name && other.phoneE164 == phoneE164;

  @override
  int get hashCode => Object.hash(name, phoneE164);
}

/// The trusted contact lives in the person's private profile, which only they
/// (and the server) can read.
abstract interface class TrustedContactRepository {
  Future<Result<TrustedContact?>> load(String uid);

  /// Null removes the contact.
  Future<Result<void>> save(String uid, TrustedContact? contact);
}

class SupabaseTrustedContactRepository implements TrustedContactRepository {
  SupabaseTrustedContactRepository(this._tables);

  final Tables _tables;

  @override
  Future<Result<TrustedContact?>> load(String uid) => runGuarded(() async {
    final rows = await _tables.select('private_profiles', where: (column: 'id', value: uid));
    final raw = rows.firstOrNull?['trusted_contact'];
    if (raw is! Map) return null;
    final name = raw['name'];
    final phone = raw['phoneE164'];
    return name is String && phone is String ? TrustedContact(name: name, phoneE164: phone) : null;
  });

  @override
  Future<Result<void>> save(String uid, TrustedContact? contact) => runGuarded(() async {
    await _tables.update(
      'private_profiles',
      {
        'trusted_contact': contact == null ? null : {'name': contact.name, 'phoneE164': contact.phoneE164},
      },
      where: [(column: 'id', value: uid)],
    );
  });
}

/// Calls, texts and the share sheet. Each returns false when nothing could
/// be opened.
abstract interface class SafetyLauncher {
  Future<bool> call(String number);

  /// A text message to [phone] (or no one yet, when null) with [body] filled in.
  Future<bool> text(String? phone, String body);

  Future<bool> share(String body);
}

class DeviceSafetyLauncher implements SafetyLauncher {
  const DeviceSafetyLauncher();

  static Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> call(String number) => _open(Uri(scheme: 'tel', path: number));

  @override
  Future<bool> text(String? phone, String body) =>
      // Built by hand: Uri.queryParameters would turn spaces into "+", which
      // some messaging apps show as is.
      _open(Uri.parse('sms:${phone ?? ''}?body=${Uri.encodeComponent(body)}'));

  @override
  Future<bool> share(String body) async {
    try {
      final result = await SharePlus.instance.share(ShareParams(text: body));
      return result.status != ShareResultStatus.unavailable;
    } on Object {
      return false;
    }
  }
}

/// A map link anyone can open, for "Send my location".
String mapLink(double lat, double lng) =>
    'https://maps.google.com/?q=${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';

/// What someone typed into an E.164 number: "+44 7700 900123" as is, or a
/// local number in the app's home country. Null when it is not valid.
String? trustedPhoneE164(String raw, {required String countryCode, required int nationalLength}) {
  final compact = raw.replaceAll(RegExp(r'[\s\-().]'), '');
  if (RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(compact)) return compact;
  if (compact.startsWith('00') && RegExp(r'^00[1-9]\d{7,14}$').hasMatch(compact)) return '+${compact.substring(2)}';
  final digits = compact.replaceFirst(RegExp('^0'), '');
  if (!RegExp(r'^\d+$').hasMatch(digits) || digits.length != nationalLength) return null;
  return '$countryCode$digits';
}
