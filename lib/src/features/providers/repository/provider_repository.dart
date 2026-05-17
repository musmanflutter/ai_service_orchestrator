import 'package:ai_service_orchestrator/src/features/providers/data/mock_providers.dart';
import 'package:ai_service_orchestrator/src/features/providers/models/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider_repository.g.dart';

class ProviderRepository {
  /// Fetches all providers (simulating network request)
  Future<List<ServiceProvider>> fetchAllProviders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockProviders;
  }
}

@Riverpod(keepAlive: true)
ProviderRepository providerRepository(Ref ref) {
  return ProviderRepository();
}
