import 'dart:async';
import 'dart:convert';

import 'package:emerald_pokedex/screens/pokedex_screen.dart';
import 'package:emerald_pokedex/services/pokemon_service.dart';
import 'package:emerald_pokedex/theme/emerald_theme.dart';
import 'package:emerald_pokedex/widgets/pokemon_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String fixture([
  List<String> names = const ['bulbasaur', 'ivysaur', 'venusaur'],
]) => jsonEncode({
  'results': [
    for (var i = 0; i < names.length; i++)
      {'name': names[i], 'url': 'https://pokeapi.co/api/v2/pokemon/${i + 1}/'},
  ],
});

Widget app(PokemonService service) => MaterialApp(
  theme: EmeraldTheme.theme,
  home: PokedexScreen(service: service),
);

void main() {
  testWidgets('shows loading then data; search and sort do not refetch', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    var calls = 0;
    final service = PokemonService(
      client: MockClient((_) {
        calls++;
        return pending.future;
      }),
    );
    addTearDown(service.dispose);
    await tester.pumpWidget(app(service));
    expect(find.text('Opening the Pokédex…'), findsOneWidget);
    pending.complete(http.Response(fixture(), 200));
    await tester.pumpAndSettle();
    expect(find.byType(PokemonCard), findsNWidgets(3));
    expect(find.text('No. 001'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ivysaur');
    await tester.pumpAndSettle();
    expect(find.byType(PokemonCard), findsOneWidget);
    expect(find.text('IVYSAUR'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sort by name'));
    await tester.pumpAndSettle();
    expect(find.text('A–Z'), findsOneWidget);
    expect(calls, 1);
  });

  testWidgets('error state retries and reaches the grid', (tester) async {
    var calls = 0;
    final service = PokemonService(
      client: MockClient(
        (_) async => ++calls == 1
            ? http.Response('', 503)
            : http.Response(fixture(), 200),
      ),
    );
    addTearDown(service.dispose);
    await tester.pumpWidget(app(service));
    await tester.pumpAndSettle();
    expect(find.text('Connection interrupted'), findsOneWidget);
    await tester.ensureVisible(find.text('TRY AGAIN'));
    await tester.tap(find.text('TRY AGAIN'));
    await tester.pumpAndSettle();
    expect(find.byType(PokemonCard), findsNWidgets(3));
    expect(calls, 2);
  });

  testWidgets('empty API response offers a reload', (tester) async {
    final service = PokemonService(
      client: MockClient((_) async => http.Response(fixture([]), 200)),
    );
    addTearDown(service.dispose);
    await tester.pumpWidget(app(service));
    await tester.pumpAndSettle();
    expect(find.text('No entries yet'), findsOneWidget);
    expect(find.text('RELOAD POKÉDEX'), findsOneWidget);
  });

  testWidgets('empty search can be cleared and padded ID search works', (
    tester,
  ) async {
    final service = PokemonService(
      client: MockClient((_) async => http.Response(fixture(), 200)),
    );
    addTearDown(service.dispose);
    await tester.pumpWidget(app(service));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'missingno');
    await tester.pumpAndSettle();
    expect(find.text('No Pokémon found'), findsOneWidget);
    await tester.ensureVisible(find.text('CLEAR SEARCH'));
    await tester.tap(find.text('CLEAR SEARCH'));
    await tester.pumpAndSettle();
    expect(find.byType(PokemonCard), findsNWidgets(3));
    await tester.enterText(find.byType(TextField), '#002');
    await tester.pumpAndSettle();
    expect(find.text('IVYSAUR'), findsOneWidget);
    expect(find.byType(PokemonCard), findsOneWidget);
  });

  testWidgets('a request completing after disposal causes no UI exception', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    final service = PokemonService(client: MockClient((_) => pending.future));
    addTearDown(service.dispose);
    await tester.pumpWidget(app(service));
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(http.Response(fixture(), 200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('grid scrolls through all 30 at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = PokemonService(
        client: MockClient(
          (_) async => http.Response(
            fixture(List.generate(30, (i) => 'pokemon-${i + 1}')),
            200,
          ),
        ),
      );
      addTearDown(service.dispose);
      await tester.pumpWidget(app(service));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final grid = tester.widget<GridView>(find.byType(GridView));
      grid.controller!.jumpTo(grid.controller!.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(find.text('No. 030'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
