import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../backend/backend_providers.dart';
import 'photo_card.dart';

/// Shows the first profile photo from Cloud Storage, or the initial-letter
/// placeholder while loading, when there is no photo, or if it fails.
class StoragePhoto extends ConsumerWidget {
  const StoragePhoto({required this.paths, required this.name, super.key});

  final List<String> paths;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = PhotoPlaceholderArt(name: name);
    if (paths.isEmpty) return placeholder;
    return FutureBuilder<String>(
      future: ref.watch(storageUrlResolverProvider).urlFor(paths.first),
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null) return placeholder;
        return Image.network(
          url,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stack) => placeholder,
          loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
        );
      },
    );
  }
}
