import 'package:pairup/features/splash/domain/entities/onboarding_page_entity.dart';

abstract class OnboardingRepository {
  List<OnboardingPageEntity> getOnboardingPages();
}
