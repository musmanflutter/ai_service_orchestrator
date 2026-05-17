// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(providerRepository)
const providerRepositoryProvider = ProviderRepositoryProvider._();

final class ProviderRepositoryProvider
    extends
        $FunctionalProvider<
          ProviderRepository,
          ProviderRepository,
          ProviderRepository
        >
    with $Provider<ProviderRepository> {
  const ProviderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProviderRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProviderRepository create(Ref ref) {
    return providerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProviderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProviderRepository>(value),
    );
  }
}

String _$providerRepositoryHash() =>
    r'01aca2ff5c4117341fd8da356715bd86eb9c76a3';
