import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/state/auth_store.dart';
import 'features/costing/presentation/pages/dashboard_page.dart';
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
      title: 'Solar ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthStore>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();

    return switch (auth.status) {
      AuthStatus.unknown => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.authenticated => const DashboardPage(),
      AuthStatus.unauthenticated => const LoginPage(),
    };
  }
}