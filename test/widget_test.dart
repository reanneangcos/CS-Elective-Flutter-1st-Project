import 'package:cs_elective_2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Netflix LeBron home screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NetflixApp());

    expect(find.text('For Reanne'), findsOneWidget);
    expect(find.text('KING JAMES'), findsOneWidget);
    expect(find.text('My List'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
