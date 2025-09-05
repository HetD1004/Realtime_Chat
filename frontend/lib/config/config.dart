class Config {
  static const String _devBaseUrl = 'http://localhost:3000/api';
  static const String _prodBaseUrl =
      'https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app/api';

  // Force production URLs when not in development environment
  static bool get _isProduction {
    // Check if running in development mode
    bool isDev = false;
    assert(() {
      isDev = true;
      return true;
    }());

    // If not in debug mode, or if the host is vercel.app, use production
    final isProduction =
        !isDev ||
        Uri.base.host.contains('vercel.app') ||
        Uri.base.host.contains('netlify.app') ||
        (Uri.base.host != 'localhost' && Uri.base.host != '127.0.0.1');

    // Debug logging
    print('🔧 Config Debug:');
    print('   isDev: $isDev');
    print('   URI.base.host: ${Uri.base.host}');
    print('   isProduction: $isProduction');
    print('   baseUrl: ${isProduction ? _prodBaseUrl : _devBaseUrl}');

    return isProduction;
  }

  static String get baseUrl => _isProduction ? _prodBaseUrl : _devBaseUrl;
  static String get socketUrl => _isProduction
      ? 'https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app'
      : 'http://localhost:3000';
}
