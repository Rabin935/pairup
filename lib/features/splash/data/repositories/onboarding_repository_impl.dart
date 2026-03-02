import 'package:pairup/features/splash/data/datasource/onboarding_local_datasource.dart';
import 'package:pairup/features/splash/domain/entities/onboarding_page_entity.dart';
import 'package:pairup/features/splash/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  const OnboardingRepositoryImpl(this._localDataSource);

  @override
  List<OnboardingPageEntity> getOnboardingPages() {
    return _localDataSource.getOnboardingPages();
  }
}
