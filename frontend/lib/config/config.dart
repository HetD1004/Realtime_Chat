class Config {
  static const String _devBaseUrl = 'http://localhost:3000/api';
  static const String _prodBaseUrl =
      'https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app/api';

  // Use a more reliable production detection
  static bool get _isProduction =>
      const bool.fromEnvironment('dart.vm.product') ||
      Uri.base.host.contains('vercel.app') ||
      Uri.base.host != 'localhost';

  static String get baseUrl => _isProduction ? _prodBaseUrl : _devBaseUrl;
  static String get socketUrl => _isProduction
      ? 'https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app'
      : 'http://localhost:3000';
}
