import 'package:cs_elective_2/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setScreenSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('uses the compact mobile layout and Material controls', (
    tester,
  ) async {
    await setScreenSize(tester, const Size(390, 844));
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(const LumenApp());

    expect(find.byKey(const ValueKey('mobile-layout')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('material-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('material-play-button')), findsOneWidget);
    expect(find.text('AFTERLIGHT'), findsOneWidget);
    expect(find.text('Save'), findsWidgets);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('switches to a navigation rail on tablet', (tester) async {
    await setScreenSize(tester, const Size(800, 1000));

    await tester.pumpWidget(const LumenApp());

    expect(find.byKey(const ValueKey('tablet-layout')), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps narrow phones free of layout overflow', (tester) async {
    await setScreenSize(tester, const Size(320, 568));

    await tester.pumpWidget(const LumenApp());

    expect(find.byKey(const ValueKey('mobile-layout')), findsOneWidget);
    expect(find.text('AFTERLIGHT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the scrollable mobile layout in short landscape windows', (
    tester,
  ) async {
    await setScreenSize(tester, const Size(844, 390));

    await tester.pumpWidget(const LumenApp());

    expect(find.byKey(const ValueKey('mobile-layout')), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the two-column desktop dashboard', (tester) async {
    await setScreenSize(tester, const Size(1440, 900));

    await tester.pumpWidget(const LumenApp());

    expect(find.byKey(const ValueKey('desktop-layout')), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byKey(const ValueKey('brand-logo')), findsOneWidget);
    expect(find.text('Wildflower'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expands desktop navigation only when space is available', (
    tester,
  ) async {
    await setScreenSize(tester, const Size(1600, 900));

    await tester.pumpWidget(const LumenApp());

    final navigationRail = tester.widget<NavigationRail>(
      find.byType(NavigationRail),
    );
    expect(navigationRail.extended, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses Cupertino controls on iOS', (tester) async {
    await setScreenSize(tester, const Size(390, 844));
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await tester.pumpWidget(const LumenApp());

    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(
      find.byKey(const ValueKey('cupertino-bottom-navigation')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cupertino-play-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('material-play-button')), findsNothing);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });
}
