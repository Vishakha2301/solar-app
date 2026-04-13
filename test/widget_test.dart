import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:solar_app/features/auth/presentation/state/auth_store.dart';
import 'package:solar_app/features/costing/presentation/state/costing_store.dart';
import 'package:solar_app/features/customer/presentation/state/customer_store.dart';
import 'package:solar_app/features/material/presentation/state/material_store.dart';
import 'package:solar_app/features/quotation/presentation/state/quotation_store.dart';
import 'package:solar_app/main.dart';
import 'package:solar_app/shared/widgets/app_loading_view.dart';

void main() {
  testWidgets('SolarApp renders auth gate when dependencies are provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(
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

    expect(find.byType(AuthGate), findsOneWidget);
    expect(find.byType(AppLoadingView), findsOneWidget);
  });
}
