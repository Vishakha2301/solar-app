import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const String _apiBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get apiBaseUrl {
    final configuredValue = _apiBaseUrlFromEnv.isEmpty
        ? 'http://localhost:8080'
        : _apiBaseUrlFromEnv;

    if (kReleaseMode && _apiBaseUrlFromEnv.isEmpty) {
      throw StateError(
        'Missing API_BASE_URL dart-define. Provide --dart-define=API_BASE_URL=https://api.example.com',
      );
    }

    final uri = Uri.tryParse(configuredValue);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError(
        'Invalid API_BASE_URL: "$configuredValue". Expected a full URL such as https://api.example.com',
      );
    }

    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError(
        'In release mode, API_BASE_URL must use HTTPS. Received: "$configuredValue"',
      );
    }

    return configuredValue;
  }
}
