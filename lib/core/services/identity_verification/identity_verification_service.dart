import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../utils/result.dart';

part 'identity_verification_service.freezed.dart';

enum IdvStep { selfie, governmentId }

enum IdDocumentType { aadhaar, passport, drivingLicence }

/// Status of one verification step after a capture is submitted.
enum IdvStatus { approved, inReview, rejected }

/// A capture session opened on the server.
@freezed
abstract class IdvSession with _$IdvSession {
  const factory IdvSession({
    required String id,
    required IdvStep step,
    required DateTime expiresAt,

    /// Cloud Storage path the capture must be uploaded to.
    required String uploadPath,
  }) = _IdvSession;
}

/// What the server decided for a capture.
@freezed
abstract class IdvOutcome with _$IdvOutcome {
  const factory IdvOutcome({
    required IdvStatus stepStatus,

    /// True once every verification step is approved.
    required bool accountApproved,

    /// Server reason code for a rejection, e.g. "underage".
    String? reason,
  }) = _IdvOutcome;
}

/// Client side of identity verification (selfie liveness and ID check).
///
/// The decision is always made and stored on the server; the app only
/// captures and uploads.
abstract interface class IdentityVerificationService {
  Future<Result<IdvSession>> startSession(IdvStep step, {IdDocumentType? documentType});

  Future<Result<IdvOutcome>> submitCapture({required IdvSession session, required Uint8List imageBytes});
}
