/// Every route path. Feature phases add their routes here.
abstract final class AppRoutes {
  static const start = '/';

  // Onboarding (Phase 2).
  static const rules = '/onboarding/rules';
  static const verify = '/onboarding/verify';
  static const preferences = '/onboarding/preferences';
  static const suspended = '/suspended';

  // Home tabs (Phase 3).
  static const discover = '/discover';
  static const freeNow = '/discover/free-now';
  static const chats = '/chats';
  static const bookings = '/bookings';
  static const profile = '/profile';
  static const saved = '/profile/saved';
  static const editProfile = '/profile/edit';

  /// Where a fully set-up person lands.
  static const home = discover;

  /// A companion's full profile (screen 8).
  static String companion(String uid) => '/companion/$uid';
  static const companionPattern = '/companion/:uid';

  /// One conversation (screen 9).
  static String chat(String chatId) => '/chat/$chatId';
  static const chatPattern = '/chat/:chatId';

  // Map and booking (Phase 4).
  static const discoverMapPath = '/discover/map';
  static const pickSpotPath = '/pick-spot';
  static const bookPath = '/book';

  /// Map from Discover; with a companion, "Pick" books them at that spot.
  static String discoverMap({String? companionUid, Enum? plan}) =>
      _withQuery(discoverMapPath, {'companion': companionUid, 'plan': plan?.name});

  /// Map in pick mode: returns the chosen venue id.
  static String pickSpot({required String companionUid, Enum? plan}) =>
      _withQuery(pickSpotPath, {'companion': companionUid, 'plan': plan?.name});

  /// Screen 6. [kind] is "scheduled" (default) or "instant".
  static String book({required String companionUid, Enum? plan, String? venueId, String? kind}) =>
      _withQuery(bookPath, {'companion': companionUid, 'plan': plan?.name, 'venue': venueId, 'kind': kind});

  static String _withQuery(String path, Map<String, String?> query) {
    final params = {
      for (final entry in query.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    return Uri(path: path, queryParameters: params.isEmpty ? null : params).toString();
  }

  /// Screen 11: credits and plans (Phase 6).
  static const credits = '/credits';

  /// Test builds only.
}
