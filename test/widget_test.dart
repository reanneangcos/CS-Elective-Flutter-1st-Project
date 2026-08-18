import 'package:flutter_test/flutter_test.dart';
import 'package:nestedscenario/main.dart';

void main() {
  testWidgets('opens the corresponding fruit route', (tester) async {
    router.go('/');
    await tester.pumpWidget(const FruitApp());
    await tester.pumpAndSettle();

    expect(find.text('Fruit Basket'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/fruit/apple');
    expect(find.text('🍎'), findsOneWidget);
    expect(
      find.text('Crisp, sweet, and perfect for an afternoon snack.'),
      findsOneWidget,
    );
  });
}
