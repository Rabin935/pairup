import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsState {
  final SettingsStatus status;
  final String? errorMessage;

  const SettingsState({this.status = SettingsStatus.initial, this.errorMessage});

  SettingsState copyWith({SettingsStatus? status, String? errorMessage}) {
    return SettingsState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

abstract class ChangeThemeUsecase {
  Future<void> call(String mode);
}

abstract class ChangeLanguageUsecase {
  Future<void> call(String languageCode);
}

abstract class EnableNotificationsUsecase {
  Future<void> call(bool enabled);
}

class SettingsViewModel {
  final ChangeThemeUsecase _changeThemeUsecase;
  final ChangeLanguageUsecase _changeLanguageUsecase;
  final EnableNotificationsUsecase _enableNotificationsUsecase;

  SettingsState state = const SettingsState();

  SettingsViewModel({
    required ChangeThemeUsecase changeThemeUsecase,
    required ChangeLanguageUsecase changeLanguageUsecase,
    required EnableNotificationsUsecase enableNotificationsUsecase,
  }) : _changeThemeUsecase = changeThemeUsecase,
       _changeLanguageUsecase = changeLanguageUsecase,
       _enableNotificationsUsecase = enableNotificationsUsecase;

  Future<void> changeTheme(String mode) async {
    state = state.copyWith(status: SettingsStatus.loading, errorMessage: null);
    try {
      await _changeThemeUsecase(mode);
      state = state.copyWith(status: SettingsStatus.success, errorMessage: null);
    } catch (error) {
      state = state.copyWith(
        status: SettingsStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    state = state.copyWith(status: SettingsStatus.loading, errorMessage: null);
    try {
      await _changeLanguageUsecase(languageCode);
      state = state.copyWith(status: SettingsStatus.success, errorMessage: null);
    } catch (error) {
      state = state.copyWith(
        status: SettingsStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> enableNotifications(bool enabled) async {
    state = state.copyWith(status: SettingsStatus.loading, errorMessage: null);
    try {
      await _enableNotificationsUsecase(enabled);
      state = state.copyWith(status: SettingsStatus.success, errorMessage: null);
    } catch (error) {
      state = state.copyWith(
        status: SettingsStatus.error,
        errorMessage: error.toString(),
      );
    }
  }
}

class MockChangeThemeUsecase extends Mock implements ChangeThemeUsecase {}

class MockChangeLanguageUsecase extends Mock implements ChangeLanguageUsecase {}

class MockEnableNotificationsUsecase extends Mock
    implements EnableNotificationsUsecase {}

void main() {
  late MockChangeThemeUsecase changeThemeUsecase;
  late MockChangeLanguageUsecase changeLanguageUsecase;
  late MockEnableNotificationsUsecase enableNotificationsUsecase;
  late SettingsViewModel viewModel;

  setUp(() {
    changeThemeUsecase = MockChangeThemeUsecase();
    changeLanguageUsecase = MockChangeLanguageUsecase();
    enableNotificationsUsecase = MockEnableNotificationsUsecase();

    viewModel = SettingsViewModel(
      changeThemeUsecase: changeThemeUsecase,
      changeLanguageUsecase: changeLanguageUsecase,
      enableNotificationsUsecase: enableNotificationsUsecase,
    );
  });

  test('SettingsViewModel change theme handles loading, success, and error states', () async {
    final successCompleter = Completer<void>();
    when(() => changeThemeUsecase.call('dark'))
        .thenAnswer((_) => successCompleter.future);

    final successFuture = viewModel.changeTheme('dark');
    expect(viewModel.state.status, SettingsStatus.loading);

    successCompleter.complete();
    await successFuture;
    expect(viewModel.state.status, SettingsStatus.success);

    final errorCompleter = Completer<void>();
    when(() => changeThemeUsecase.call('dark'))
        .thenAnswer((_) => errorCompleter.future);

    final errorFuture = viewModel.changeTheme('dark');
    expect(viewModel.state.status, SettingsStatus.loading);

    errorCompleter.completeError(Exception('theme failed'));
    await errorFuture;
    expect(viewModel.state.status, SettingsStatus.error);
    expect(viewModel.state.errorMessage, contains('theme failed'));
  });

  test('SettingsViewModel change language handles loading, success, and error states', () async {
    final successCompleter = Completer<void>();
    when(() => changeLanguageUsecase.call('ne'))
        .thenAnswer((_) => successCompleter.future);

    final successFuture = viewModel.changeLanguage('ne');
    expect(viewModel.state.status, SettingsStatus.loading);

    successCompleter.complete();
    await successFuture;
    expect(viewModel.state.status, SettingsStatus.success);

    final errorCompleter = Completer<void>();
    when(() => changeLanguageUsecase.call('ne'))
        .thenAnswer((_) => errorCompleter.future);

    final errorFuture = viewModel.changeLanguage('ne');
    expect(viewModel.state.status, SettingsStatus.loading);

    errorCompleter.completeError(Exception('language failed'));
    await errorFuture;
    expect(viewModel.state.status, SettingsStatus.error);
    expect(viewModel.state.errorMessage, contains('language failed'));
  });

  test('SettingsViewModel enable notifications handles loading, success, and error states', () async {
    final successCompleter = Completer<void>();
    when(() => enableNotificationsUsecase.call(true))
        .thenAnswer((_) => successCompleter.future);

    final successFuture = viewModel.enableNotifications(true);
    expect(viewModel.state.status, SettingsStatus.loading);

    successCompleter.complete();
    await successFuture;
    expect(viewModel.state.status, SettingsStatus.success);

    final errorCompleter = Completer<void>();
    when(() => enableNotificationsUsecase.call(true))
        .thenAnswer((_) => errorCompleter.future);

    final errorFuture = viewModel.enableNotifications(true);
    expect(viewModel.state.status, SettingsStatus.loading);

    errorCompleter.completeError(Exception('notifications failed'));
    await errorFuture;
    expect(viewModel.state.status, SettingsStatus.error);
    expect(viewModel.state.errorMessage, contains('notifications failed'));
  });
}
