abstract final class AppDefaults {
  static const defaultApiBaseUrl = String.fromEnvironment('REMOTE_COPILOT_API_URL', defaultValue: 'http://localhost:8080');
}
