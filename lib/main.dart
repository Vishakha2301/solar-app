import 'package:flutter/material.dart';
import 'package:solar_app/features/costing/presentation/pages/dashboard_page.dart';
import 'core/theme/app_theme.dart';

import 'package:provider/provider.dart';
import 'features/costing/presentation/state/costing_store.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CostingStore(),
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
      home: const DashboardPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Project Costing'),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Renewable Energy App 🌱⚡',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    );
  }
}
