import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pairup/core/localization/app_localizations.dart';

const MethodChannel _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void setupFlutterSecureStorageMock({String? token}) {
  TestWidgetsFlutterBinding.ensureInitialized();

  _secureStorageChannel.setMockMethodCallHandler((call) async {
    switch (call.method) {
      case 'read':
        final key = call.arguments['key']?.toString();
        if (key == 'auth_token') {
          return token;
        }
        return null;
      case 'write':
      case 'delete':
      case 'deleteAll':
      case 'containsKey':
        return null;
      case 'readAll':
        return <String, String>{};
      default:
        return null;
    }
  });
}

void tearDownFlutterSecureStorageMock() {
  _secureStorageChannel.setMockMethodCallHandler(null);
}

Widget withTestMaterialApp(
  Widget child, {
  List overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      home: child,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

Map<String, dynamic> jsonResponse(Map<String, dynamic> data) {
  return jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
}
