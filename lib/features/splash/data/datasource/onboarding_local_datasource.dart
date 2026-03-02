import 'package:pairup/features/splash/data/models/onboarding_page_model.dart';

abstract class OnboardingLocalDataSource {
  List<OnboardingPageModel> getOnboardingPages();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl();

  @override
  List<OnboardingPageModel> getOnboardingPages() {
    return const [
      OnboardingPageModel(
        imageUrl: 'assets/images/onboardimage1.jpg',
        title: 'Meet New People With Real Intentions',
        description:
            'Discover meaningful profiles, chat naturally, and build genuine connections.',
      ),
      OnboardingPageModel(
        imageUrl: 'assets/images/onboardimage2.jpg',
        title: 'Match Beyond Just Photos',
        description:
            'Find users by interests, lifestyle, and compatibility so every match feels relevant.',
      ),
      OnboardingPageModel(
        imageUrl: 'assets/images/onboardimage3.jpg',
        title: 'Start Your Next Story On PairUp',
        description:
            'Your next close connection can begin with a single swipe and a simple hello.',
      ),
    ];
  }
}
