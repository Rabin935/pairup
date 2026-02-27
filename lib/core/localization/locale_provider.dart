import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/localization/app_localizations.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  static const _localeKey = 'app_locale_code';
  late final SharedPreferences _prefs;

  @override
  Locale? build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final languageCode = _prefs.getString(_localeKey)?.trim();
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }

    final locale = Locale(languageCode);
    final isSupported = AppLocalizations.supportedLocales.any(
      (item) => item.languageCode == locale.languageCode,
    );
    return isSupported ? locale : null;
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(_localeKey);
      return;
    }
    await _prefs.setString(_localeKey, locale.languageCode);
  }
}
