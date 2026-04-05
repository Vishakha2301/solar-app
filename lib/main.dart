import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_app/features/costing/presentation/pages/dashboard_page.dart';
import 'package:solar_app/features/auth/presentation/state/auth_store.dart';
import 'package:solar_app/features/auth/presentation/pages/login_page.dart';
import 'core/theme/app_theme.dart';
import 'features/costing/presentation/state/costing_store.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStore()),
        ChangeNotifierProvider(create: (_) => CostingStore()),
      ],
      child: const SolarApp(),
    ),
  );
}

class SolarApp extends StatelessWidget {
  const SolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar Project App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGuard(),
    );
  }
}

class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    // Check if user is logged in when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthStore>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStore>(
      builder: (context, authStore, _) {
        switch (authStore.status) {
          case AuthStatus.authenticated:
            return const DashboardPage();
          case AuthStatus.unauthenticated:
            return const LoginPage();
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
