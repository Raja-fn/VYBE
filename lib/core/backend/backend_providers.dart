import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'callable_client.dart';
import 'file_storage.dart';
import 'tables.dart';

part 'backend_providers.g.dart';

/// Set up in `bootstrap()` (Supabase.initialize). Tests override the providers below instead.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

@Riverpod(keepAlive: true)
Tables tables(Ref ref) => SupabaseTables(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
CallableClient callableClient(Ref ref) => SupabaseCallableClient(ref.watch(supabaseClientProvider).functions);

@Riverpod(keepAlive: true)
FileUploader fileUploader(Ref ref) => SupabaseStorageUploader(ref.watch(supabaseClientProvider).storage);

@Riverpod(keepAlive: true)
StorageUrlResolver storageUrlResolver(Ref ref) => SupabaseStorageUrlResolver(ref.watch(supabaseClientProvider).storage);
