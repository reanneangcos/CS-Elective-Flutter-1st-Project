import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sole_select/main.dart';
import 'package:sole_select/screens/home_screen.dart';
import 'package:sole_select/theme/app_theme.dart';
import 'package:sole_select/widgets/product_card.dart';

void main() {
  // This test covers the exact required user flow from the exam document.
  testWidgets('shop flow reaches checkout confirmation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SoleSelectApp());
    await tester.pumpAndSettle();

    expect(find.text('SOLE/SELECT'), findsOneWidget);
    expect(find.byKey(const Key('product-grid')), findsOneWidget);

    await tester.tap(find.text('Strata One'));
    await tester.pumpAndSettle();
    expect(find.text('ADD TO CART'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    expect(find.textContaining('SIZE 7 ADDED'), findsOneWidget);

    await tester.tap(find.byKey(const Key('view-cart')));
    await tester.pumpAndSettle();
    expect(find.text('YOUR CART'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.ensureVisible(find.byKey(const Key('checkout-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout-button')));
    await tester.pumpAndSettle();
    expect(find.text('ORDER CONFIRMED'), findsOneWidget);
    expect(find.byKey(const Key('confirmation-total')), findsOneWidget);
    expect(find.textContaining('ORDER ID: SS-O-'), findsOneWidget);
  });

  testWidgets('catalog filters, search, and sorting are functional', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(768, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SoleSelectApp());
    await tester.pumpAndSettle();

    expect(find.text('8 RESULTS'), findsOneWidget);

    // Tablet width must display at least three products on the same row.
    final tabletCards = find.byType(ProductCard);
    final tabletFirst = tester.getTopLeft(tabletCards.at(0));
    final tabletThird = tester.getTopLeft(tabletCards.at(2));
    final tabletFourth = tester.getTopLeft(tabletCards.at(3));
    expect(tabletThird.dy, tabletFirst.dy);
    expect(tabletFourth.dy, greaterThan(tabletFirst.dy));

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

  testWidgets('shopping flow has no overflow on a compact mobile screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SoleSelectApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('catalog-scroll')), findsOneWidget);
    expect(find.byKey(const Key('product-grid')), findsOneWidget);

    // The rubric explicitly requires two columns at phone width.
    final phoneCards = find.byType(ProductCard);
    final firstCard = tester.getTopLeft(phoneCards.at(0));
    final secondCard = tester.getTopLeft(phoneCards.at(1));
    final thirdCard = tester.getTopLeft(phoneCards.at(2));
    expect(secondCard.dx, greaterThan(firstCard.dx));
    expect(secondCard.dy, firstCard.dy);
    expect(thirdCard.dy, greaterThan(firstCard.dy));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Strata One'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Strata One'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('add-to-cart')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('view-cart')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cart-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 5));
    await tester.ensureVisible(find.byKey(const Key('checkout-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('checkout-button')));
    await tester.pumpAndSettle();
    expect(find.text('ORDER CONFIRMED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme toggle updates the whole app', (tester) async {
    await tester.pumpWidget(const SoleSelectApp());
    await tester.pumpAndSettle();

    BuildContext appContext() => tester.element(find.byType(HomeScreen));

    expect(Theme.of(appContext()).brightness, Brightness.light);
    await tester.tap(find.byTooltip('Use dark mode'));
    await tester.pumpAndSettle();
    expect(Theme.of(appContext()).brightness, Brightness.dark);

    final selectedChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'ALL'),
    );
    expect(
      selectedChip.labelStyle?.color,
      AppTheme.dark.colorScheme.onSecondary,
    );
  });

  testWidgets('same product in different sizes creates separate cart lines', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SoleSelectApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Strata One'));
    await tester.pumpAndSettle();
    expect(find.text('PRODUCT ID: SS-P001'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-to-cart'))); // Size 7.
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '8'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('add-to-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-to-cart'))); // Size 8.
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('view-cart')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart-line-SS-P001-US7')), findsOneWidget);
    expect(find.byKey(const Key('cart-line-SS-P001-US8')), findsOneWidget);
    expect(find.text('SS-P001 · SIZE US 7'), findsOneWidget);
    expect(find.text('SS-P001 · SIZE US 8'), findsOneWidget);
  });

  testWidgets('checkout redirects to cart when the cart is empty', (
    tester,
  ) async {
    await tester.pumpWidget(const SoleSelectApp());
    await tester.pumpAndSettle();

    // Calling a URL directly verifies the Navigation 2.0 route guard.
    tester.element(find.byType(HomeScreen)).go('/checkout');
    await tester.pumpAndSettle();

    expect(find.text('YOUR CART IS EMPTY'), findsOneWidget);
    expect(find.text('ORDER CONFIRMED'), findsNothing);
  });
}
