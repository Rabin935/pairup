import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/features/splash/data/datasource/onboarding_local_datasource.dart';
import 'package:pairup/features/splash/data/repositories/onboarding_repository_impl.dart';
import 'package:pairup/features/splash/domain/entities/onboarding_page_entity.dart';
import 'package:pairup/features/splash/domain/repositories/onboarding_repository.dart';
import 'package:pairup/features/splash/domain/usecases/get_onboarding_pages_usecase.dart';

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((
  ref,
) {
  return const OnboardingLocalDataSourceImpl();
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingLocalDataSourceProvider));
});

final getOnboardingPagesUseCaseProvider = Provider<GetOnboardingPagesUseCase>((
  ref,
) {
  return GetOnboardingPagesUseCase(ref.watch(onboardingRepositoryProvider));
});

final onboardingPagesProvider = Provider<List<OnboardingPageEntity>>((ref) {
  return ref.watch(getOnboardingPagesUseCaseProvider).call();
});
