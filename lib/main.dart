import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/services.dart';
import 'screens/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TimeGridApp());
}

class TimeGridApp extends StatelessWidget {
  const TimeGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..initialize()),
        ChangeNotifierProxyProvider<AuthService, OnboardingService>(
          create: (context) => OnboardingService(context.read<AuthService>()),
          update: (context, auth, previous) => previous ?? OnboardingService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, VideoService>(
          create: (context) => VideoService(context.read<AuthService>()),
          update: (context, auth, previous) => previous ?? VideoService(auth),
        ),
        ChangeNotifierProxyProvider<AuthService, TimeClockService>(
          create: (context) => TimeClockService(context.read<AuthService>()),
          update: (context, auth, previous) => previous ?? TimeClockService(auth),
        ),
      ],
      child: MaterialApp(
        title: 'TimeGrid',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => _RouteHandler(routeName: settings.name),
          );
        },
      ),
    );
  }
}

class _RouteHandler extends StatelessWidget {
  final String? routeName;

  const _RouteHandler({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final isAuthenticated = auth.isAuthenticated;

        switch (routeName) {
          case '/onboarding':
            if (!isAuthenticated) {
              return const LoginScreen();
            }
            return const OnboardingPortal();

          case '/timeclock':
            if (!isAuthenticated) {
              return const LoginScreen();
            }
            return const TimeClockScreen();

          case '/':
          default:
            if (!isAuthenticated) {
              return LoginScreen(
                onLoginSuccess: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
              );
            }
            return const DashboardScreen();
        }
      },
    );
  }
}
