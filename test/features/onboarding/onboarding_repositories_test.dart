import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:vybe/core/backend/callable_client.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/features/onboarding/data/account_repository.dart';
import 'package:vybe/features/onboarding/data/auth_repository.dart';
import 'package:vybe/features/onboarding/domain/account.dart';
import 'package:vybe/features/onboarding/domain/session_stage.dart';
import 'package:vybe/features/preferences/data/preferences_repository.dart';
import 'package:vybe/features/preferences/domain/preferences.dart';

import '../../helpers/fake_tables.dart';
import '../../helpers/fakes.dart';

void main() {
  group('SupabaseAccountRepository', () {
    late FakeTables tables;
    late FakeCallableClient functions;
    late SupabaseAccountRepository repository;

    setUp(() {
      tables = FakeTables();
      functions = FakeCallableClient();
      repository = SupabaseAccountRepository(tables: tables, functions: functions);
    });

    test('emits null when there is no account yet', () async {
      expect(await repository.watchAccount(testUid).first, isNull);
    });

    test('reads the account row', () async {
      tables.seed('users', [
        {
          'id': testUid,
          'account_type': 'member',
          'verification_status': 'pending',
          'verification_steps': {'phone': 'approved', 'selfie': 'in_review', 'id': 'not_started'},
          'account_status': 'active',
          'verification_reason': null,
          'display_name': 'Aarav',
          'age_years': null,
          'consent': {'rulesVersion': 1},
        },
      ]);
      final account = (await repository.watchAccount(testUid).first)!;
      expect(account.uid, testUid);
      expect(account.displayName, 'Aarav');
      expect(account.verificationSteps.selfie, StepStatus.inReview);
      expect(account.isVerified, isFalse);
    });

    test('updates live when the server changes the account', () async {
      final seen = <VerificationStatus?>[];
      final sub = repository.watchAccount(testUid).listen((a) => seen.add(a?.verificationStatus));
      await pumpEventQueue();
      tables.seed('users', [
        {
          'id': testUid,
          'account_type': 'member',
          'account_status': 'active',
          'verification_status': 'approved',
          'verification_steps': {'phone': 'approved', 'selfie': 'approved', 'id': 'approved'},
        },
      ]);
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, [null, VerificationStatus.approved]);
    });

    test('tolerates unknown values from a newer server', () async {
      tables.seed('users', [
        {
          'id': testUid,
          'account_type': 'something_new',
          'verification_status': 'something_new',
          'verification_steps': {'phone': 'approved', 'selfie': 'something_new', 'id': 'not_started'},
          'account_status': 'something_new',
        },
      ]);
      final account = (await repository.watchAccount(testUid).first)!;
      expect(account.accountType, AccountType.member);
      expect(account.verificationStatus, VerificationStatus.pending);
      expect(account.verificationSteps.selfie, StepStatus.notStarted);
      expect(account.accountStatus, AccountStatus.active);
    });

    test('acceptRules calls the server with the rules version', () async {
      final result = await repository.acceptRules(rulesVersion: 1, dateOfBirth: DateTime(2000, 1, 5));
      expect(result.isOk, isTrue);
      expect(functions.calls.single.$1, 'acceptRules');
      expect(functions.calls.single.$2, {'rulesVersion': 1, 'ageConfirmed': true, 'dateOfBirth': '2000-01-05'});
    });

    test('acceptRules returns a typed failure instead of throwing', () async {
      functions.error = const ServerException('unavailable');
      expect(
        (await repository.acceptRules(rulesVersion: 1, dateOfBirth: DateTime(2000))).failureOrNull?.kind,
        FailureKind.network,
      );
    });
  });

  group('SupabasePreferencesRepository', () {
    late FakeTables tables;
    late SupabasePreferencesRepository repository;
    const prefs = Preferences(
      gender: Gender.nonBinary,
      showMe: ShowMe.everyone,
      ageMin: 21,
      ageMax: 35,
      showGender: false,
      whoCanRequest: WhoCanRequest.everyone,
    );

    setUp(() {
      tables = FakeTables();
      repository = SupabasePreferencesRepository(tables);
    });

    test('emits null before anything is saved', () async {
      expect(await repository.watch(testUid).first, isNull);
    });

    test('saves the columns the database expects', () async {
      expect((await repository.save(testUid, prefs)).isOk, isTrue);
      final (kind, table, row) = tables.writes.single;
      expect((kind, table), ('upsert', 'preferences'));
      expect(row, {
        'uid': testUid,
        'gender': 'non_binary',
        'show_me': 'everyone',
        'age_min': 21,
        'age_max': 35,
        'show_gender': false,
        'who_can_request': 'everyone',
      });
    });

    test('reads back what it saved', () async {
      await repository.save(testUid, prefs);
      expect(await repository.watch(testUid).first, prefs);
    });
  });

  group('SupabaseAuthRepository', () {
    test('Continue with Google exchanges the Google token for a session, and sign-out forgets it', () async {
      final server = _AuthServer();
      final picker = _FakePicker()..token = 'google-id-token';
      final repository = server.repository(picker);
      final states = <AuthUser?>[];
      final sub = repository.watchUser().listen(states.add);

      expect((await repository.signInWithGoogle()).isOk, isTrue);
      final request = server.requests.singleWhere((r) => r.url.path.endsWith('/token'));
      expect(request.url.queryParameters['grant_type'], 'id_token');
      expect(jsonDecode(request.body), containsPair('id_token', 'google-id-token'));
      expect(jsonDecode(request.body), containsPair('provider', 'google'));

      await repository.signOut();
      await pumpEventQueue();
      await sub.cancel();
      expect(picker.signOuts, 1);
      expect(states, [null, const AuthUser(uid: testUid, email: 'test@example.com'), null]);
    });

    test('closing the picker is a cancel, a missing setup is explained', () async {
      final server = _AuthServer();
      expect(
        (await server.repository(_FakePicker()).signInWithGoogle()).failureOrNull?.kind,
        FailureKind.signInCanceled,
      );
      final broken = _FakePicker()..failure = const AppFailure(FailureKind.googleSignInUnavailable);
      expect(
        (await server.repository(broken).signInWithGoogle()).failureOrNull?.kind,
        FailureKind.googleSignInUnavailable,
      );
      expect(server.requests, isEmpty);
    });

    test('test accounts work only in test builds, and a new one is created on first use', () async {
      final server = _AuthServer()..passwordAccounts.clear();
      expect(
        (await server.repository(_FakePicker()).signInWithTestGoogleAccount('aarav@findx.test')).failureOrNull?.kind,
        FailureKind.permissionDenied,
      );
      final repository = server.repository(_FakePicker(), allowTestAccounts: true);
      expect((await repository.signInWithTestGoogleAccount(' Neha@FindX.test ')).isOk, isTrue);
      expect(server.requests.map((r) => r.url.path.split('/').last), ['token', 'signup']);
      expect(jsonDecode(server.requests.last.body), containsPair('email', 'neha@findx.test'));
      expect(jsonDecode(server.requests.last.body), containsPair('password', 'test-password'));
    });

    test('an existing test account signs in with the shared password', () async {
      final server = _AuthServer();
      final repository = server.repository(_FakePicker(), allowTestAccounts: true);
      expect((await repository.signInWithTestGoogleAccount('aarav@findx.test')).isOk, isTrue);
      expect(server.requests.single.url.queryParameters['grant_type'], 'password');
    });

    test('asks the server for a code, then signs in with the token it returns', () async {
      final server = _AuthServer();
      final functions = FakeCallableClient()..responses['verifyLoginOtp'] = {'tokenHash': 'hashed-token'};
      final repository = server.repository(_FakePicker(), functions: functions);

      final sent = await repository.requestOtp(testPhone);
      expect((sent.valueOrNull! as OtpCodeSent).verificationId, testPhone);
      expect(functions.calls.first.$1, 'requestLoginOtp');
      expect(functions.calls.first.$2, {'phone': testPhone});

      expect((await repository.confirmOtp(verificationId: testPhone, code: ' 1234 ')).isOk, isTrue);
      expect(functions.calls.last.$1, 'verifyLoginOtp');
      expect(functions.calls.last.$2, {'phone': testPhone, 'code': '1234'});
      final verify = server.requests.singleWhere((r) => r.url.path.endsWith('/verify'));
      expect(jsonDecode(verify.body), containsPair('token_hash', 'hashed-token'));
      expect(jsonDecode(verify.body), containsPair('type', 'magiclink'));
    });

    test('deleting the account asks the server, then ends the session', () async {
      final server = _AuthServer();
      final functions = FakeCallableClient();
      final picker = _FakePicker()..token = 'google-id-token';
      final repository = server.repository(picker, functions: functions);
      await repository.signInWithGoogle();

      expect((await repository.deleteAccount()).isOk, isTrue);
      expect(functions.calls.single.$1, 'deleteAccount');
      expect(await repository.watchUser().first, isNull);
      expect(picker.signOuts, 1);
    });

    test('if the server cannot delete the account, the person stays signed in', () async {
      final server = _AuthServer();
      final functions = FakeCallableClient()..error = const ServerException('unavailable');
      final repository = server.repository(_FakePicker()..token = 't', functions: functions);
      await repository.signInWithGoogle();
      expect((await repository.deleteAccount()).failureOrNull?.kind, FailureKind.network);
      expect(await repository.watchUser().first, isNotNull);
    });

    test('a phone-login account has its number, and no placeholder email', () {
      final user = User.fromJson({
        'id': testUid,
        'aud': 'authenticated',
        'email': '919876543210@phone.findx.invalid',
        'app_metadata': {'phone_e164': testPhone},
        'user_metadata': <String, Object?>{},
        'created_at': '2026-11-13T00:00:00Z',
      })!;
      expect(SupabaseAuthRepository.toAuthUser(user), const AuthUser(uid: testUid, phoneNumber: testPhone));
    });

    for (final (code, kind) in [
      ('otp_wrong', FailureKind.wrongCode),
      ('otp_expired', FailureKind.codeExpired),
      ('otp_send_failed', FailureKind.otpSendFailed),
      ('rate_limited', FailureKind.rateLimited),
    ]) {
      test('server code $code becomes $kind', () async {
        final functions = FakeCallableClient()..error = ServerException('failed-precondition', code: code);
        final repository = _AuthServer().repository(_FakePicker(), functions: functions);
        final result = code == 'otp_send_failed' || code == 'rate_limited'
            ? await repository.requestOtp(testPhone)
            : await repository.confirmOtp(verificationId: testPhone, code: '1234');
        expect(result.failureOrNull?.kind, kind);
      });
    }
  });
}

/// A stand-in for Supabase Auth's HTTP API.
class _AuthServer {
  final List<http.Request> requests = [];
  final Set<String> passwordAccounts = {'aarav@findx.test'};

  Map<String, Object?> _session(String email) => {
    'access_token': 'access-token',
    'token_type': 'bearer',
    'expires_in': 3600,
    'expires_at': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    'refresh_token': 'refresh-token',
    'user': {
      'id': testUid,
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': email,
      'app_metadata': {'provider': 'google'},
      'user_metadata': <String, Object?>{},
      'created_at': '2026-11-13T00:00:00Z',
    },
  };

  late final client = MockClient((request) async {
    requests.add(request);
    final path = request.url.path;
    final body = request.body.isEmpty ? <String, Object?>{} : jsonDecode(request.body) as Map<String, Object?>;
    http.Response json(Object value, [int status = 200]) => http.Response(
      jsonEncode(value),
      status,
      // Real Supabase Auth names its API version; error reasons are then in `code`.
      headers: {'content-type': 'application/json', 'x-supabase-api-version': '2024-01-01'},
    );
    if (path.endsWith('/token')) {
      final grant = request.url.queryParameters['grant_type'];
      if (grant == 'password' && !passwordAccounts.contains(body['email'])) {
        return json({'code': 'invalid_credentials', 'msg': 'Invalid login credentials'}, 400);
      }
      return json(_session((body['email'] as String?) ?? 'test@example.com'));
    }
    if (path.endsWith('/signup')) return json(_session(body['email']! as String));
    if (path.endsWith('/verify')) return json(_session('919876543210@phone.findx.invalid'));
    if (path.endsWith('/logout')) return http.Response('', 204);
    return json({'msg': 'not found'}, 404);
  });

  SupabaseAuthRepository repository(
    GoogleAccountPicker picker, {
    FakeCallableClient? functions,
    bool allowTestAccounts = false,
  }) => SupabaseAuthRepository(
    GoTrueClient(
      url: 'https://test.supabase.co/auth/v1',
      httpClient: client,
      autoRefreshToken: false,
      flowType: AuthFlowType.implicit,
    ),
    functions: functions ?? FakeCallableClient(),
    google: picker,
    allowTestAccounts: allowTestAccounts,
    testAccountPassword: 'test-password',
  );
}

class _FakePicker implements GoogleAccountPicker {
  String? token;
  AppFailure? failure;
  int signOuts = 0;

  @override
  Future<String?> pickIdToken() async {
    final error = failure;
    if (error != null) throw error;
    return token;
  }

  @override
  Future<void> signOut() async => signOuts += 1;
}
