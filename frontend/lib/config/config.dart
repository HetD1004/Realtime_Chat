class Config {
  static const String _devBaseUrl = 'http://localhost:3000/api';
  static const String _prodBaseUrl =
      'https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app/api';

  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl => _isProduction ? _prodBaseUrl : _devBaseUrl;
  static String get socketUrl => _isProduction
      ? 'https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app'
      : 'http://localhost:3000';
}
