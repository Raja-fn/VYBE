import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/domain/session_stage.dart';
import '../../features/onboarding/presentation/session_providers.dart';
import '../backend/backend_providers.dart';
import '../router/app_router.dart';

/// The phone's notification service, behind an interface for tests.
abstract interface class PushClient {
  /// Asks to show notifications (Android 13+ and iOS). True when allowed.
  Future<bool> requestPermission();

  /// This phone's address for notifications, or null when there is none.
  Future<String?> token();

  Stream<String> get tokenRefresh;

  /// Where to go when a notification is tapped while the app is running in the background.
  Stream<String> get openedRoutes;

  /// The notification that started the app, if any.
  Future<String?> initialRoute();
}

class FirebasePushClient implements PushClient {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  static String? _routeOf(RemoteMessage message) {
    final route = message.data['route'];
    return route is String && route.startsWith('/') ? route : null;
  }

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // The server sends with FCM HTTP v1 to registration tokens; the newer
  // register()/onRegistered gives installation ids, which it does not use.
  @override
  // ignore: deprecated_member_use
  Future<String?> token() => _messaging.getToken();

  @override
  // ignore: deprecated_member_use
  Stream<String> get tokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<String> get openedRoutes =>
      FirebaseMessaging.onMessageOpenedApp.map(_routeOf).where((r) => r != null).cast<String>();

  @override
  Future<String?> initialRoute() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _routeOf(message);
  }
}

final pushClientProvider = Provider<PushClient>((ref) => FirebasePushClient());

/// Keeps this phone registered for the signed-in person's notifications and
/// opens the right screen when one is tapped. Watched by the app root.
final pushRegistrationProvider = NotifierProvider<PushRegistration, void>(PushRegistration.new);

class PushRegistration extends Notifier<void> {
  String? _registeredUid;
  String? _token;
  final _subscriptions = <StreamSubscription<String>>[];

  @override
  void build() {
    final client = ref.watch(pushClientProvider);
    ref.onDispose(() {
      for (final s in _subscriptions) {
        unawaited(s.cancel());
      }
      _subscriptions.clear();
    });
    _subscriptions
      ..add(client.openedRoutes.listen(_open))
      ..add(
        client.tokenRefresh.listen((token) {
          final uid = _registeredUid;
          if (uid != null) unawaited(_register(uid, token));
        }),
      );
    unawaited(client.initialRoute().then((route) => route == null ? null : _open(route)).catchError((_) {}));

    // Register once the person has an account (the server keeps tokens on it).
    ref.listen(sessionStageProvider, (_, next) {
      final stage = next.value;
      final uid = switch (stage) {
        NeedsVerification(:final account) || NeedsPreferences(:final account) || Ready(:final account) => account.uid,
        _ => null,
      };
      if (uid != null && uid != _registeredUid) unawaited(_start(uid));
      if (stage is SignedOut) _registeredUid = null;
    }, fireImmediately: true);
  }

  void _open(String route) => ref.read(appRouterProvider).go(route);

  Future<void> _start(String uid) async {
    _registeredUid = uid;
    try {
      final client = ref.read(pushClientProvider);
      if (!await client.requestPermission()) return;
      final token = await client.token();
      if (token != null) await _register(uid, token);
    } on Object catch (error) {
      debugPrint('Notifications are not available: $error');
    }
  }

  Future<void> _register(String uid, String token) async {
    if (!ref.mounted || _registeredUid != uid) return;
    _token = token;
    try {
      await ref.read(callableClientProvider).call('registerPushToken', {'token': token});
    } on Object catch (error) {
      debugPrint('Could not register for notifications: $error');
    }
  }

  /// Before signing out: this phone stops getting this person's notifications.
  Future<void> unregister() async {
    final token = _token;
    _registeredUid = null;
    _token = null;
    if (token == null) return;
    try {
      await ref.read(callableClientProvider).call('unregisterPushToken', {'token': token});
    } on Object catch (error) {
      debugPrint('Could not unregister notifications: $error');
    }
  }
}
