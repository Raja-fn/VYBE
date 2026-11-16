import 'dart:typed_data';

import '../../utils/app_failure.dart';
import '../../utils/clock.dart';
import '../../utils/result.dart';
import 'identity_verification_service.dart';

/// Test stand-in for the identity verification client.
///
/// The running app always uses the server client; on the test project
/// the server-side fake provider makes the decision.
class FakeIdentityVerificationService implements IdentityVerificationService {
  FakeIdentityVerificationService({
    required Clock clock,
    required Duration sessionLifetime,
    this.outcome = const IdvOutcome(stepStatus: IdvStatus.approved, accountApproved: false),
  }) : _clock = clock,
       _sessionLifetime = sessionLifetime;

  final Clock _clock;
  final Duration _sessionLifetime;
  IdvOutcome outcome;
  int _sessionCounter = 0;

  /// Every session started, in order.
  final List<IdvSession> sessions = [];

  @override
  Future<Result<IdvSession>> startSession(IdvStep step, {IdDocumentType? documentType}) async {
    if (step == IdvStep.governmentId && documentType == null) {
      return const Err(AppFailure(FailureKind.invalidInput, debugMessage: 'Missing document type'));
    }
    _sessionCounter += 1;
    final id = 'fake-idv-${step.name}-$_sessionCounter';
    final session = IdvSession(
      id: id,
      step: step,
      expiresAt: _clock.now().add(_sessionLifetime),
      uploadPath: 'verification/test/$id.jpg',
    );
    sessions.add(session);
    return Ok(session);
  }

  @override
  Future<Result<IdvOutcome>> submitCapture({required IdvSession session, required Uint8List imageBytes}) async {
    if (imageBytes.isEmpty) {
      return const Err(AppFailure(FailureKind.invalidInput, debugMessage: 'Empty capture'));
    }
    if (!_clock.now().isBefore(session.expiresAt)) {
      return const Err(AppFailure(FailureKind.invalidInput, debugMessage: 'Session expired'));
    }
    return Ok(outcome);
  }
}
