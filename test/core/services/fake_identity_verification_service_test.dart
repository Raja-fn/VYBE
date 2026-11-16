import 'dart:typed_data';

import 'package:findx/core/backend/callable_client.dart';
import 'package:findx/core/services/identity_verification/fake_identity_verification_service.dart';
import 'package:findx/core/services/identity_verification/functions_identity_verification_service.dart';
import 'package:findx/core/services/identity_verification/identity_verification_service.dart';
import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/core/utils/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  final image = Uint8List.fromList([1, 2, 3]);

  group('FakeIdentityVerificationService (test double)', () {
    late FixedClock clock;
    late FakeIdentityVerificationService service;

    setUp(() {
      clock = FixedClock(DateTime.utc(2026, 11, 10, 10));
      service = FakeIdentityVerificationService(clock: clock, sessionLifetime: const Duration(minutes: 15));
    });

    test('starts a session that expires after the lifetime', () async {
      final session = (await service.startSession(IdvStep.selfie)).valueOrNull!;
      expect(session.expiresAt, DateTime.utc(2026, 11, 10, 10, 15));
    });

    test('needs a document type for the ID step', () async {
      expect((await service.startSession(IdvStep.governmentId)).failureOrNull?.kind, FailureKind.invalidInput);
    });

    test('returns the configured outcome', () async {
      service.outcome = const IdvOutcome(stepStatus: IdvStatus.rejected, accountApproved: false);
      final session = (await service.startSession(IdvStep.selfie)).valueOrNull!;
      expect(
        (await service.submitCapture(session: session, imageBytes: image)).valueOrNull?.stepStatus,
        IdvStatus.rejected,
      );
    });

    test('rejects empty and expired captures', () async {
      final session = (await service.startSession(IdvStep.selfie)).valueOrNull!;
      expect(
        (await service.submitCapture(session: session, imageBytes: Uint8List(0))).failureOrNull?.kind,
        FailureKind.invalidInput,
      );
      clock.current = clock.current.add(const Duration(minutes: 15));
      expect(
        (await service.submitCapture(session: session, imageBytes: image)).failureOrNull?.kind,
        FailureKind.invalidInput,
      );
    });
  });

  group('FunctionsIdentityVerificationService', () {
    late FakeCallableClient functions;
    late FakeFileUploader uploader;
    late FunctionsIdentityVerificationService service;

    setUp(() {
      functions = FakeCallableClient()
        ..responses['startVerification'] = {
          'sessionId': 'sess-1',
          'uploadPath': 'verification/u/sess-1.jpg',
          'expiresAt': '2026-11-10T10:15:00.000Z',
        }
        ..responses['submitVerification'] = {
          'step': 'id',
          'stepStatus': 'approved',
          'verificationStatus': 'approved',
          'reason': null,
        };
      uploader = FakeFileUploader();
      service = FunctionsIdentityVerificationService(functions: functions, uploader: uploader);
    });

    test('starts a selfie session', () async {
      final session = (await service.startSession(IdvStep.selfie)).valueOrNull!;
      expect(functions.calls.single.$1, 'startVerification');
      expect(functions.calls.single.$2, {'step': 'selfie'});
      expect(session.uploadPath, 'verification/u/sess-1.jpg');
      expect(session.expiresAt, DateTime.utc(2026, 11, 10, 10, 15));
    });

    test('sends the document type for the ID step', () async {
      await service.startSession(IdvStep.governmentId, documentType: IdDocumentType.drivingLicence);
      expect(functions.calls.single.$2, {'step': 'id', 'documentType': 'driving_licence'});
    });

    test('uploads to the session path, then asks the server to decide', () async {
      final session = (await service.startSession(
        IdvStep.governmentId,
        documentType: IdDocumentType.aadhaar,
      )).valueOrNull!;
      final outcome = (await service.submitCapture(session: session, imageBytes: image)).valueOrNull!;
      expect(uploader.uploads.single, ('verification/u/sess-1.jpg', 3));
      expect(functions.calls.last.$1, 'submitVerification');
      expect(functions.calls.last.$2, {'sessionId': 'sess-1'});
      expect(outcome, const IdvOutcome(stepStatus: IdvStatus.approved, accountApproved: true));
    });

    test('maps an in-review decision and a rejection reason', () async {
      functions.responses['submitVerification'] = {
        'stepStatus': 'rejected',
        'verificationStatus': 'rejected',
        'reason': 'underage',
      };
      final session = (await service.startSession(IdvStep.selfie)).valueOrNull!;
      final outcome = (await service.submitCapture(session: session, imageBytes: image)).valueOrNull!;
      expect(outcome.stepStatus, IdvStatus.rejected);
      expect(outcome.reason, 'underage');

      functions.responses['submitVerification'] = {'stepStatus': 'in_review', 'verificationStatus': 'pending'};
      final later = (await service.submitCapture(session: session, imageBytes: image)).valueOrNull!;
      expect(later.stepStatus, IdvStatus.inReview);
    });

    test('refuses an empty capture without uploading', () async {
      final session = (await service.startSession(IdvStep.selfie)).valueOrNull!;
      final result = await service.submitCapture(session: session, imageBytes: Uint8List(0));
      expect(result.failureOrNull?.kind, FailureKind.invalidInput);
      expect(uploader.uploads, isEmpty);
    });

    test('turns server errors into typed failures', () async {
      functions.error = const ServerException('unavailable');
      expect((await service.startSession(IdvStep.selfie)).failureOrNull?.kind, FailureKind.network);
    });
  });
}
