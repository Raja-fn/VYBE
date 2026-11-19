import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Opens web pages and email, behind an interface for tests.
abstract interface class LinkOpener {
  Future<bool> open(Uri uri);
}

class DeviceLinkOpener implements LinkOpener {
  const DeviceLinkOpener();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}

final linkOpenerProvider = Provider<LinkOpener>((ref) => const DeviceLinkOpener());

/// Opens [uri]; says so when nothing on the phone can open it.
Future<void> openLink(BuildContext context, WidgetRef ref, Uri uri) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final opened = await ref.read(linkOpenerProvider).open(uri);
  if (!opened) messenger.showSnackBar(SnackBar(content: Text(l10n.linkOpenFailed(uri.toString()))));
}

Uri mailTo(String email, {String? subject}) =>
    Uri(scheme: 'mailto', path: email, query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}');

/// "Terms · Privacy policy" in small print.
class LegalLinks extends ConsumerWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final config = ref.watch(appConfigProvider);
    final style = TextButton.styleFrom(
      foregroundColor: AppColors.accentText,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          style: style,
          onPressed: () => openLink(context, ref, Uri.parse(config.termsUrl)),
          child: Text(l10n.legalTerms),
        ),
        Text('·', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
        TextButton(
          style: style,
          onPressed: () => openLink(context, ref, Uri.parse(config.privacyPolicyUrl)),
          child: Text(l10n.legalPrivacy),
        ),
      ],
    );
  }
}
