import 'dart:typed_data';

import '../../backend/callable_client.dart';
import '../../backend/file_storage.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import '../../utils/run_guarded.dart';
import 'identity_verification_service.dart';

/// Talks to the server's `startVerification` / `submitVerification` actions.
///
/// Used on the test project and in production alike: the server picks the fake or
/// the real provider.
class FunctionsIdentityVerificationService implements IdentityVerificationService {
  FunctionsIdentityVerificationService({required CallableClient functions, required FileUploader uploader})
    : _functions = functions,
      _uploader = uploader;

  final CallableClient _functions;
  final FileUploader _uploader;

  static const _documentTypes = {
    IdDocumentType.aadhaar: 'aadhaar',
    IdDocumentType.passport: 'passport',
    IdDocumentType.drivingLicence: 'driving_licence',
  };

  @override
  Future<Result<IdvSession>> startSession(IdvStep step, {IdDocumentType? documentType}) => runGuarded(() async {
    final data = await _functions.call('startVerification', {
      'step': step == IdvStep.selfie ? 'selfie' : 'id',
      if (documentType != null) 'documentType': _documentTypes[documentType],
    });
    return IdvSession(
      id: data['sessionId']! as String,
      step: step,
      expiresAt: DateTime.parse(data['expiresAt']! as String),
      uploadPath: data['uploadPath']! as String,
    );
  });

  @override
  Future<Result<IdvOutcome>> submitCapture({required IdvSession session, required Uint8List imageBytes}) {
    if (imageBytes.isEmpty) {
      return Future.value(const Err(AppFailure(FailureKind.invalidInput, debugMessage: 'Empty capture')));
    }
    return runGuarded(() async {
      await _uploader.uploadJpeg(session.uploadPath, imageBytes);
      final data = await _functions.call('submitVerification', {'sessionId': session.id});
      return IdvOutcome(
        stepStatus: switch (data['stepStatus']) {
          'approved' => IdvStatus.approved,
          'rejected' => IdvStatus.rejected,
          _ => IdvStatus.inReview,
        },
        accountApproved: data['verificationStatus'] == 'approved',
        reason: data['reason'] as String?,
      );
    });
  }
}
