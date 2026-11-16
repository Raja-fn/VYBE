import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_providers.dart';
import '../data/preferences_repository.dart';
import '../domain/preferences.dart';

part 'preferences_providers.g.dart';

@Riverpod(keepAlive: true)
PreferencesRepository preferencesRepository(Ref ref) => SupabasePreferencesRepository(ref.watch(tablesProvider));

@Riverpod(keepAlive: true)
Stream<Preferences?> preferences(Ref ref, String uid) => ref.watch(preferencesRepositoryProvider).watch(uid);
