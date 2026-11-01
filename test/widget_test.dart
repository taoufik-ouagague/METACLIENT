import 'package:flutter_test/flutter_test.dart';
import 'package:metaclient/main.dart';
import 'package:metaclient/services/api_service.dart';
import 'package:metaclient/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    ApiService.init();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MetaClientApp());
    // Pump frames to let splash screen timer complete
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(MetaClientApp), findsOneWidget);
  });
}

