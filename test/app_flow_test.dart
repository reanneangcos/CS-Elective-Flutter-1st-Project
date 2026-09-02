import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sole_select/main.dart';

void main() {
  testWidgets('shop flow reaches checkout confirmation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SoleSelectApp());
    await tester.pumpAndSettle();

    expect(find.text('SOLE/SELECT'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.text('Strata One'));
    await tester.pumpAndSettle();
    expect(find.text('ADD TO CART'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    expect(find.text('VIEW CART'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    expect(find.text('YOUR CART'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.ensureVisible(find.byKey(const Key('checkout-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout-button')));
    await tester.pumpAndSettle();
    expect(find.text('ORDER CONFIRMED'), findsOneWidget);
    expect(find.byKey(const Key('confirmation-total')), findsOneWidget);
  });

  testWidgets('catalog filters, search, and sorting are functional', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(768, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SoleSelectApp());
    await tester.pumpAndSettle();

    expect(find.text('8 RESULTS'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'TRAIL'));
    await tester.pumpAndSettle();
    expect(find.text('2 RESULTS'), findsOneWidget);
    expect(find.text('Ridge Form'), findsOneWidget);
    expect(find.text('Dune Trek'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'ALL'));
    await tester.enterText(find.byType(SearchBar), 'Harbor');
    await tester.pumpAndSettle();
    expect(find.text('1 RESULT'), findsOneWidget);
    expect(find.text('Harbor Court'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sort products'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Price: high to low'));
    await tester.pumpAndSettle();

    final dunePosition = tester.getTopLeft(find.text('Dune Trek'));
    final ridgePosition = tester.getTopLeft(find.text('Ridge Form'));
    expect(dunePosition.dy, lessThanOrEqualTo(ridgePosition.dy));
  });
}
