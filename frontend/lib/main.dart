import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'services/chat_provider.dart';
import 'services/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

import 'screens/dashboard_screen.dart';

void main() {
  // Force cache bust - v2.1.0 FINAL
  print(
    '🚀🚀🚀 POLLING SERVICE v2.1.0 FINAL - Build ${DateTime.now().millisecondsSinceEpoch}',
  );
  print('🔥🔥🔥 NO WEBSOCKETS - ONLY HTTP POLLING - FINAL VERSION');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'REAL-TIME CHAT APP',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/dashboard': (context) => const DashboardScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'REAL-TIME CHAT APP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          // Set current user in chat provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ChatProvider>().setCurrentUser(
              authProvider.currentUser!,
            );
          });
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
