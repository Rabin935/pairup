import 'package:pairup/features/splash/domain/entities/onboarding_page_entity.dart';
import 'package:pairup/features/splash/domain/repositories/onboarding_repository.dart';

class GetOnboardingPagesUseCase {
  final OnboardingRepository _repository;

  const GetOnboardingPagesUseCase(this._repository);

  List<OnboardingPageEntity> call() {
    return _repository.getOnboardingPages();
  }
}
