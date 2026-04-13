import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/navigation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/state/auth_store.dart';
import 'features/costing/presentation/state/costing_store.dart';
import 'features/customer/presentation/state/customer_store.dart';
import 'features/material/presentation/state/material_store.dart';
import 'features/quotation/presentation/state/quotation_store.dart';
import 'shared/widgets/app_loading_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStore()),
        ChangeNotifierProvider(create: (_) => CostingStore()),
        ChangeNotifierProvider(create: (_) => CustomerStore()),
        ChangeNotifierProvider(create: (_) => MaterialStore()),
        ChangeNotifierProvider(create: (_) => QuotationStore()),
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
      title: AppStrings.appTitle,
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
      AuthStatus.unknown => const AppLoadingView(),
      AuthStatus.authenticated => const AppShell(),
      AuthStatus.unauthenticated => const LoginPage(),
    };
  }
}
