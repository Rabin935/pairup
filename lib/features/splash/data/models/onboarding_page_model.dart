import 'package:pairup/features/splash/domain/entities/onboarding_page_entity.dart';

class OnboardingPageModel extends OnboardingPageEntity {
  const OnboardingPageModel({
    required super.imageUrl,
    required super.title,
    required super.description,
  });

  factory OnboardingPageModel.fromMap(Map<String, dynamic> map) {
    return OnboardingPageModel(
      imageUrl: map['imageUrl'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }
}
