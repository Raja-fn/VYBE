import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/clock.dart';

/// "Resend code in 24s", then a "Resend code" button.
class ResendCodeButton extends ConsumerStatefulWidget {
  const ResendCodeButton({required this.sentAt, required this.enabled, required this.onResend, super.key});

  final DateTime sentAt;
  final bool enabled;
  final VoidCallback onResend;

  @override
  ConsumerState<ResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends ConsumerState<ResendCodeButton> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final waitSeconds = ref.watch(appConfigProvider).otpResendSeconds;
    final elapsed = ref.watch(clockProvider).now().difference(widget.sentAt).inSeconds;
    final remaining = waitSeconds - elapsed;

    if (remaining > 0) {
      return TextButton(onPressed: null, child: Text(l10n.verifyResendIn(remaining)));
    }
    _ticker?.cancel();
    return TextButton(onPressed: widget.enabled ? widget.onResend : null, child: Text(l10n.verifyResend));
  }
}
