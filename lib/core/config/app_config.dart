class AppConfig {
  AppConfig._();

  /// Default API base URL for Android emulator is http://10.0.2.2:8000/api/v1.
  /// - For iOS simulator: http://127.0.0.1:8000/api/v1
  /// - For real device: `http://<LAN_IP>:8000/api/v1` (e.g. `http://192.168.1.100:8000/api/v1`)
  /// - Overridable at compile time: --dart-define=API_BASE_URL=http://...
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  /// URL of the companion web application.
  /// - Overridable at compile time: --dart-define=WEB_URL=http://...
  static const String webUrl = String.fromEnvironment(
    'WEB_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
