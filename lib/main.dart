import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/services.dart';
import 'screens/screens.dart';
import 'theme/app_theme.dart';
import 'widgets/common/bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
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
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              return _RouteHandler(routeName: settings.name);
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return _buildPageTransition(animation, child);
            },
            transitionDuration: const Duration(milliseconds: 350),
          );
        },
      ),
    );
  }

  static Widget _buildPageTransition(
    Animation<double> animation,
    Widget child,
  ) {
    const begin = Offset(0.0, 0.05);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
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

          case '/time-off-details':
            if (!isAuthenticated) {
              return const LoginScreen();
            }
            return const TimeOffDetailsScreen();

          case '/request-time-off':
            if (!isAuthenticated) {
              return const LoginScreen();
            }
            return const RequestTimeOffScreen();

          case '/add-document':
            if (!isAuthenticated) {
              return const LoginScreen();
            }
            return const AddDocumentScreen();

          case '/time-off-history':
            if (!isAuthenticated) {
              return const LoginScreen();
            }
            return const TimeOffHistoryScreen();

          case '/':
          default:
            if (!isAuthenticated) {
              return LoginScreen(
                onLoginSuccess: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
              );
            }
            return const MainNavigationShell();
        }
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboardScreen(),
    const ChatListScreen(),
    const _PlaceholderScreen(icon: Icons.add_circle_outline, label: 'Actions'),
    const _PlaceholderScreen(icon: Icons.account_balance_wallet_outlined, label: 'Payroll'),
    const _PlaceholderScreen(icon: Icons.note_alt_outlined, label: 'Notes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlaceholderScreen({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
