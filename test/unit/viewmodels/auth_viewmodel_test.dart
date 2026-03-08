import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pairup/features/auth/domain/usecases/login_usecase.dart';
import 'package:pairup/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pairup/features/auth/domain/usecases/register_usecase.dart';
import 'package:pairup/features/auth/presentation/state/auth_state.dart';
import 'package:pairup/features/auth/presentation/view_model/auth_viewmodel.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockRegisterUsecase registerUsecase;
  late MockLoginUsecase loginUsecase;
  late MockGetCurrentUserUsecase getCurrentUserUsecase;
  late MockLogoutUsecase logoutUsecase;
  late ProviderContainer container;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    registerUsecase = MockRegisterUsecase();
    loginUsecase = MockLoginUsecase();
    getCurrentUserUsecase = MockGetCurrentUserUsecase();
    logoutUsecase = MockLogoutUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWith((ref) => registerUsecase),
        loginUsecaseProvider.overrideWith((ref) => loginUsecase),
        getCurrentUserUsecaseProvider.overrideWith((ref) => getCurrentUserUsecase),
        logoutUsecaseProvider.overrideWith((ref) => logoutUsecase),
      ],
    );

    addTearDown(container.dispose);
  });

  test('AuthViewModel login handles loading, success, and error states', () async {
    when(() => loginUsecase(any<LoginUsecaseParams>()))
        .thenAnswer((_) async => rightResult(sampleAuthEntity));

    final notifier = container.read(authViewModelProvider.notifier);

    final successFuture = notifier.login('alex@pairup.app', 'password123');
    expect(container.read(authViewModelProvider).status, AuthStatus.loading);

    await successFuture;
    expect(container.read(authViewModelProvider).status, AuthStatus.authenticated);

    when(() => loginUsecase(any<LoginUsecaseParams>()))
        .thenAnswer((_) async => leftResult('invalid credentials'));

    final errorFuture = notifier.login('alex@pairup.app', 'wrong');
    expect(container.read(authViewModelProvider).status, AuthStatus.loading);

    await errorFuture;
    final errorState = container.read(authViewModelProvider);
    expect(errorState.status, AuthStatus.error);
    expect(errorState.errorMessage, 'invalid credentials');
  });

  test('AuthViewModel register handles loading, success, and error states', () async {
    when(() => registerUsecase(any<RegisterUsecaseParams>()))
        .thenAnswer((_) async => rightResult(true));

    final notifier = container.read(authViewModelProvider.notifier);

    final successFuture = notifier.register(
      firstname: 'Alex',
      lastname: 'Ray',
      email: 'alex@pairup.app',
      password: 'password123',
      phoneNumber: '+15550000000',
    );
    expect(container.read(authViewModelProvider).status, AuthStatus.loading);

    await successFuture;
    expect(container.read(authViewModelProvider).status, AuthStatus.registered);

    when(() => registerUsecase(any<RegisterUsecaseParams>()))
        .thenAnswer((_) async => leftResult('email exists'));

    final errorFuture = notifier.register(
      firstname: 'Alex',
      lastname: 'Ray',
      email: 'alex@pairup.app',
      password: 'password123',
      phoneNumber: '+15550000000',
    );
    expect(container.read(authViewModelProvider).status, AuthStatus.loading);

    await errorFuture;
    final errorState = container.read(authViewModelProvider);
    expect(errorState.status, AuthStatus.error);
    expect(errorState.errorMessage, 'email exists');
  });
}
