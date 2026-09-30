# Emerald Pokédex

A Flutter implementation of **Async Activity.pptx** for CS Elective 2. The interface borrows Pokémon Emerald's forest greens, cream panels, pixel lettering, and Generation III sprites. The list contains National Pokédex entries 001–030 as returned by the activity's endpoint.

## Run

Requires Flutter with Dart 3.12.2 or newer, and an internet connection for PokéAPI and sprite images.

```sh
flutter pub get
flutter run -d chrome
```

For Android, start an emulator or connect a device, then run `flutter run`. Internet permission is included in the main Android manifest so release builds can also fetch data.

## Activity requirements

| PPT requirement | Implementation |
| --- | --- |
| Fetch from PokéAPI, limited to 30 | `PokemonService` requests `https://pokeapi.co/api/v2/pokemon?limit=30&offset=0` and caps the parsed list at 30. |
| Scrollable grid with name, image, and ID | `PokemonCard` renders a name, Emerald sprite, and padded Pokédex number in a responsive `GridView.builder`. |
| Future or Stream, with explanation | `Future<List<Pokemon>>` consumed by a `FutureBuilder`; explanation below. |
| Loading, error, and empty states | Loading indicator; readable network/server/timeout/format errors with retry; empty API response with reload. Failed images have a fallback. |
| Models, services, widgets, screens | Separate folders under `lib/`, using Dart's lowercase naming conventions. |
| End at the grid | Cards have no detail route or detail page. |
| Branch `pokedex-act` | Local Git repository initialized on that branch. Publishing awaits the repository URL. |

Search by name or number and toggle numerical/alphabetical sorting. Both operate on the loaded list without additional requests. Search has its own no-results state and clear button.

## Why a Future?

The HTTP GET request finishes with **one result**: a list of 30 Pokémon, or an error. `Future<List<Pokemon>>` models that single eventual result. A `Stream` represents multiple events over time, such as a live chat or sensor feed. This endpoint has no live subscription, so a Stream would add unnecessary complexity.

`fetchPokemon()` uses `async/await` and `try/catch`. The service has a 15-second timeout, validates JSON and resource IDs, and caches successful results in memory for its lifetime. Empty results and failures can be retried. The UI creates its Future in `initState()` and replaces it only on retry, so typing and sorting do not restart the request. `FutureBuilder` handles completion and errors; there is no manual `setState` after an `await`. The screen disposes its text/scroll controllers and owned HTTP service.

## Structure

```text
lib/
  main.dart
  models/pokemon.dart
  services/pokemon_service.dart
  screens/pokedex_screen.dart
  widgets/
    dex_header.dart
    dex_state_panel.dart
    pokeball.dart
    pokemon_card.dart
  theme/emerald_theme.dart
test/
  pokemon_service_test.dart
  pokedex_screen_test.dart
assets/fonts/
```

## Checks

```sh
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

Tests use mock HTTP responses and cover the 30-item limit, caching, timeouts, malformed data, network/server failures, retry, empty responses, search/sort without refetching, disposal during a request, and scrolling at phone and landscape sizes. Browser preview checks use the real API and images.

## Submission

Work remains local as requested. Once a GitHub repository is supplied, connect it, commit the project, and push `pokedex-act`. Submit a branch-specific URL in Daigler:

```text
https://github.com/<owner>/<repository>/tree/pokedex-act
```

No repository has been published and no Daigler submission has been made.

## Sources and assets

- [PokéAPI documentation](https://pokeapi.co/docs/v2) for pagination and Pokémon resources.
- [PokéAPI sprites](https://github.com/PokeAPI/sprites) for `generation-iii/emerald/{id}.png`. IDs are extracted from the resource URLs in the API response, avoiding 30 extra detail requests. Images load over HTTPS and use nearest-neighbor rendering.
- [Flutter FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html) for stable Future lifecycle guidance.
- Silkscreen and Space Mono are bundled from [Google Fonts](https://github.com/google/fonts), with their SIL Open Font License files in `assets/fonts/`.

This is an educational fan project. Pokémon names and sprites belong to their respective owners.
