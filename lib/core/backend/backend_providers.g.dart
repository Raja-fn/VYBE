// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Set up in `bootstrap()` (Supabase.initialize). Tests override the providers below instead.

@ProviderFor(supabaseClient)
const supabaseClientProvider = SupabaseClientProvider._();

/// Set up in `bootstrap()` (Supabase.initialize). Tests override the providers below instead.

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Set up in `bootstrap()` (Supabase.initialize). Tests override the providers below instead.
  const SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'3db2a4c212c7f24cea9810e376225aa1a6cab012';

@ProviderFor(tables)
const tablesProvider = TablesProvider._();

final class TablesProvider extends $FunctionalProvider<Tables, Tables, Tables>
    with $Provider<Tables> {
  const TablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tablesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tablesHash();

  @$internal
  @override
  $ProviderElement<Tables> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Tables create(Ref ref) {
    return tables(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Tables value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Tables>(value),
    );
  }
}

String _$tablesHash() => r'3835369bcc5d57bad3f2b6bc1cdf014c6d4e97e8';

@ProviderFor(callableClient)
const callableClientProvider = CallableClientProvider._();

final class CallableClientProvider
    extends $FunctionalProvider<CallableClient, CallableClient, CallableClient>
    with $Provider<CallableClient> {
  const CallableClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callableClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callableClientHash();

  @$internal
  @override
  $ProviderElement<CallableClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CallableClient create(Ref ref) {
    return callableClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallableClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallableClient>(value),
    );
  }
}

String _$callableClientHash() => r'11e8276e83aa9ef8118e2589f415e169d69f09ad';

@ProviderFor(fileUploader)
const fileUploaderProvider = FileUploaderProvider._();

final class FileUploaderProvider
    extends $FunctionalProvider<FileUploader, FileUploader, FileUploader>
    with $Provider<FileUploader> {
  const FileUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileUploaderHash();

  @$internal
  @override
  $ProviderElement<FileUploader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileUploader create(Ref ref) {
    return fileUploader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileUploader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileUploader>(value),
    );
  }
}

String _$fileUploaderHash() => r'5f3c77df1fca05778767753de1f284b5004b7da0';

@ProviderFor(storageUrlResolver)
const storageUrlResolverProvider = StorageUrlResolverProvider._();

final class StorageUrlResolverProvider
    extends
        $FunctionalProvider<
          StorageUrlResolver,
          StorageUrlResolver,
          StorageUrlResolver
        >
    with $Provider<StorageUrlResolver> {
  const StorageUrlResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageUrlResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageUrlResolverHash();

  @$internal
  @override
  $ProviderElement<StorageUrlResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StorageUrlResolver create(Ref ref) {
    return storageUrlResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageUrlResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageUrlResolver>(value),
    );
  }
}

String _$storageUrlResolverHash() =>
    r'5167ab890d88a383cfa1b4bf4c569640f2dc999a';
