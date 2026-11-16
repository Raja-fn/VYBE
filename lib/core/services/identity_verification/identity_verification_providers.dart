import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/backend_providers.dart';
import 'functions_identity_verification_service.dart';
import 'identity_verification_service.dart';

part 'identity_verification_providers.g.dart';

/// Always the server client. Which provider (fake or real) decides
/// is chosen on the server, so the test project exercises the real app flow.
@Riverpod(keepAlive: true)
IdentityVerificationService identityVerificationService(Ref ref) => FunctionsIdentityVerificationService(
  functions: ref.watch(callableClientProvider),
  uploader: ref.watch(fileUploaderProvider),
);
