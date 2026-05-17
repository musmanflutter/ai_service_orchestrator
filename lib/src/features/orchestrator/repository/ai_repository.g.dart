// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiRepository)
const aiRepositoryProvider = AiRepositoryProvider._();

final class AiRepositoryProvider
    extends $FunctionalProvider<AIRepository, AIRepository, AIRepository>
    with $Provider<AIRepository> {
  const AiRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiRepositoryHash();

  @$internal
  @override
  $ProviderElement<AIRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AIRepository create(Ref ref) {
    return aiRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AIRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AIRepository>(value),
    );
  }
}

String _$aiRepositoryHash() => r'e980e5a6a3b27577628c46617e91d646eca87418';
