# Legendary Pokédex: code explanation guide

Use this guide with the files open in your editor. Start with the overall flow, then explain each file in the order below.

## 1. Introduce the project

> “This is a Flutter Pokédex that displays Legendary Pokémon from every generation. It gets data from PokéAPI and shows each Pokémon's name, sprite, and National Pokédex number. Users can search and sort the list. The app also handles loading, errors, and empty results.”

The current response contains 71 species. The app calculates its total from the response, so that number is not hard-coded. Each species appears once. The filter follows PokéAPI's `is_legendary` field; Mythical Pokémon use a separate classification.

## 2. Explain the data flow

```text
main()
  → EmeraldPokedexApp
  → PokedexScreen.initState()
  → PokemonService.fetchPokemon()
  → HTTP POST to PokéAPI
  → JSON response → List<Pokemon>
  → FutureBuilder receives the result
  → Search and sort produce the visible list
  → GridView.builder displays PokemonCard widgets
```

Images load separately through each card's image URL. One request retrieves the species data; it does not retrieve every image as well.

> “The model represents data, the service handles networking, the screen manages state and layout, and the widgets display reusable interface parts.”

## 3. `lib/main.dart`: start the application

- `import 'package:flutter/material.dart'` makes Flutter's Material widgets available.
- `main()` is the entry point.
- `runApp(const EmeraldPokedexApp())` attaches the root widget to Flutter.
- `EmeraldPokedexApp` extends `StatelessWidget` because it has no changing local state.
- `build()` returns the widget tree for this part of the app.
- `MaterialApp` supplies app-level Material behavior, navigation, and theming.
- `title` names the app. `debugShowCheckedModeBanner: false` hides the debug banner.
- `theme` applies `EmeraldTheme.theme`, and `home` opens `PokedexScreen`.

**What to say:** “This file starts Flutter, applies the theme, and chooses the first screen.”

## 4. `lib/models/pokemon.dart`: represent one Pokémon

### Fields and constructor

| Field | Type | Meaning |
| --- | --- | --- |
| `id` | `int` | National Pokédex number, such as 384 |
| `name` | `String` | API name, such as `rayquaza` |
| `isLegendary` | `bool` | Whether the species is classified as Legendary |

`required` means callers must supply the value. `final` prevents reassignment after construction. The `const` constructor allows constant instances when all arguments are compile-time constants.

### Getters

A getter is used like a field but calculates a value:

- `number` converts the ID to text and pads it to at least three digits. Four-digit IDs such as `1024` remain intact.
- `imageUrl` builds the sprite URL using the ID. IDs through 386 use Emerald sprites; later species use the general sprite collection.
- `displayName` handles `Ho-Oh` and `Type: Null`, then replaces hyphens with spaces in other names. The card makes the displayed name uppercase.

### `Pokemon.fromJson()`

This factory constructor converts a decoded JSON map into a model. It requires a nonempty name, a positive integer ID, and a boolean Legendary flag. Invalid values throw `FormatException`.

Example input:

```json
{"id": 384, "name": "rayquaza", "is_legendary": true}
```

**What to say:** “The model converts raw API values into a predictable Dart object and prepares the fields needed by the interface.”

## 5. `lib/services/pokemon_service.dart`: load the archive

### Exception, constructor, and fields

`PokemonServiceException` contains a readable `message`; its `toString()` returns that message.

The service accepts an optional `http.Client`, allowing tests to inject a mock. Otherwise it creates a real client. The timeout defaults to 15 seconds. `endpoint` stores the API URL, `query` stores the GraphQL request, and `_cache` stores a successful list in memory.

A leading underscore makes a name private to its Dart library.

### Explain the GraphQL query

```graphql
query LegendaryPokemon {
  pokemonspecies(
    where: {is_legendary: {_eq: true}}
    order_by: {id: asc}
  ) {
    id
    name
    is_legendary
  }
}
```

- `LegendaryPokemon` names the query.
- `pokemonspecies` selects species records.
- `where` filters records. `_eq: true` means the Legendary flag must equal true.
- `order_by` requests ascending ID order.
- The final block chooses the three fields required by the model.
- There is no `limit`, so all matching species are included.

GraphQL describes the data wanted from an API. Here, the query is sent as JSON in an HTTP POST to `https://graphql.pokeapi.co/v1beta2`. This replaces the original first-30 REST request.

### Walk through `fetchPokemon()`

1. Return `_cache` immediately if a successful list is already available.
2. Call `_client.post()`. The `Content-Type` header identifies JSON, and `jsonEncode()` converts the query map into the request body.
3. `await` waits for the response while the network operation is pending. `.timeout(timeout)` limits how long the service waits.
4. Check the HTTP status. A non-200 response becomes a readable service error.
5. `jsonDecode()` converts response text into Dart maps and lists.
6. Check GraphQL `errors`. A query can fail even when HTTP reports 200, so both checks matter. Partial data accompanied by errors is rejected.
7. Read and validate `data['pokemonspecies']`.
8. `map()` converts each entry through `Pokemon.fromJson()`.
9. `where()` keeps Legendary entries as a second check. `sort()` puts the list in ascending ID order.
10. Cache a nonempty result and return an unmodifiable list. Callers cannot accidentally change its contents.

Empty lists and failed requests are not cached, so the user can retry.

### Explain the asynchronous return type

```dart
Future<List<Pokemon>> fetchPokemon() async
```

> “The function returns a Future that will eventually complete with a list of Pokémon or an error. The `async` keyword lets me use `await` while the request is pending.”

`await` does not create a new isolate or move every line into the background. Parsing and sorting still run normally after the response arrives.

### Errors and cleanup

| Failure | User-facing result |
| --- | --- |
| Timeout | Message that the connection took too long |
| Client/network failure | Message to check the connection |
| Invalid JSON or fields | Message that the data is unreadable |
| HTTP or GraphQL error | Message that the archive is unavailable |

`dispose()` closes the HTTP client when it is no longer needed.

**What to say:** “The service owns requests, validation, caching, and readable errors. The interface does not need to understand the API response format.”

## 6. `lib/screens/pokedex_screen.dart`: manage state and layout

### Why `StatefulWidget`?

The screen changes when data arrives or the user searches, sorts, or retries. `PokedexScreen` holds widget configuration, and `_PokedexScreenState` holds changing values. Its optional `service` parameter lets tests supply controlled data.

| State field | Purpose |
| --- | --- |
| `_service` | Access the API service |
| `_pokemonFuture` | Store the active request's Future |
| `_searchController` | Control the search field |
| `_scrollController` | Control grid scrolling |
| `_query` | Store normalized search text |
| `_sortByName` | Select alphabetical or numerical order |

### Lifecycle and action methods

- `initState()` runs once for this State object. It chooses the service and starts loading.
- The Future is stored here instead of being created in `build()`, so typing and sorting do not start another request.
- `_retry()` gets a new Future and stores it inside `setState()`. The `mounted` check ensures this State is still attached to the widget tree.
- `_search()` trims the text, makes it lowercase, updates state, and scrolls back to the top if the controller has an attached scroll position.
- `_clearSearch()` clears both the text controller and query.
- `dispose()` releases the controllers. It closes the service only if the screen created it; an injected service is owned by its caller.

`setState()` tells Flutter that values changed and the screen needs to rebuild. It does not automatically fetch data.

### Main layout

`Scaffold` provides the screen structure. `DecoratedBox` draws the gradient. `SafeArea` avoids system interface areas. `Center` and `ConstrainedBox` limit desktop width to 1100 pixels. `Padding`, `Column`, and `Expanded` arrange the header, main panel, and bottom message.

### `FutureBuilder<List<Pokemon>>`

`FutureBuilder` listens to the stored Future. Its `AsyncSnapshot` describes the request's state, data, or error.

`ready` means the Future completed without an error. `all` contains the returned archive, while `visible` contains search matches.

Search checks the API name, the readable display name, and the formatted number. It removes a leading `#` when matching numbers. `contains()` allows partial searches.

`toList()` creates a separate visible list. Alphabetical sorting changes that copy, preserving the cached list's numerical order.

### `_toolbar()`

Displays the title, total count, search field, clear button, and sort button. Search and sorting are disabled until usable data exists. The sort button toggles `_sortByName` and returns the grid to the top.

### `_content()`

Selects the body in this order:

1. Pending request → loading panel.
2. Failed request → error panel and Try Again.
3. Successful empty list → empty panel and Reload.
4. No search matches → no-results panel and Clear Search.
5. Otherwise → Pokémon grid.

`LayoutBuilder` measures available width. Dividing by 175 and clamping between 2 and 5 chooses the column count. `GridView.builder` creates cards as needed around the viewport. `Scrollbar` shares its scroll controller. `ValueKey` identifies each card by its Pokémon ID across list changes.

### `_footer()`

Shows visible and total counts, such as `1 / 71 Pokémon`, plus the data source. Both numbers come from the actual lists.

**What to say:** “FutureBuilder handles loading the archive, while local state handles search and sorting.”

## 7. `lib/widgets/pokemon_card.dart`: display a Pokémon

`PokemonCard` is a `StatelessWidget` that receives one model.

- `Semantics` supplies a readable number and name for assistive technology. `ExcludeSemantics` prevents repeated child announcements.
- `DecoratedBox` draws the background, border, and shadow.
- The top row displays the number and a small Poké Ball.
- `Expanded` and `LayoutBuilder` size the image area.
- `Stack` places the image over a decorative background.
- `Image.network` downloads `pokemon.imageUrl`.
- `frameBuilder` shows a placeholder until an image frame is available.
- `errorBuilder` shows a fallback and “No image” if the image fails.
- `FilterQuality.none` preserves sharp pixel edges when scaling sprites.
- `FittedBox` scales down long names and wide number labels, including four-digit IDs on narrow screens.

**What to say:** “The card displays its model. Images load separately, so an image failure does not remove the name or number.”

## 8. Other reusable widgets

### `lib/widgets/dex_header.dart`

Displays the logo, title, and edition. `LayoutBuilder` checks for a width below 600 pixels. Compact layouts use smaller sizing; wider layouts also show the Legendary archive label and “All Generations.”

### `lib/widgets/dex_state_panel.dart`

Shared by loading, error, empty, and no-results states. The caller supplies `title`, `message`, and optional action values.

- `loading` controls the progress indicator.
- `onAction` and `actionLabel` control the button.
- Compact spacing and `SingleChildScrollView` let the panel fit short screens.
- `Semantics(liveRegion: true)` helps announce state changes.
- Conditional collection elements such as `if (...) ...[...]` add widgets only when needed.

### `lib/widgets/pokeball.dart`

`Pokeball` wraps a `CustomPaint`. `_PokeballPainter` draws it using a canvas:

1. Calculate its center, radius, and circular boundary.
2. Save the canvas state and clip drawing to the circle.
3. Paint the cream base, colored top half, and center stripe.
4. Restore the canvas, then draw the outline and center button.

`muted` chooses a softer color. `shouldRepaint()` compares that flag with the previous painter. `ExcludeSemantics` marks the graphic as decorative.

**What to say:** “Separate widgets let me reuse the same visuals and keep the main screen easier to read.”

## 9. `lib/theme/emerald_theme.dart`: shared styling

`EmeraldTheme` centralizes the design:

- Color constants define the forest background, paper panels, text, borders, and accents.
- `pixel()` creates a Silkscreen `TextStyle` with a chosen size and color.
- `ThemeData` enables Material 3, sets Space Mono as the normal font, and defines the color scheme.
- `filledButtonTheme` gives action buttons consistent sizing, colors, corners, and typography.
- `abstract final class` prevents this utility class from being instantiated or extended.

**What to say:** “Shared styling lives in one file so I can adjust the appearance consistently.”

## 10. Supporting files

| File or folder | Role |
| --- | --- |
| `pubspec.yaml` | Metadata, Dart version constraint, dependencies, and bundled fonts |
| `pubspec.lock` | Exact resolved dependency versions |
| `analysis_options.yaml` | Flutter lint rules |
| `assets/fonts/` | Font files and their licenses |
| `android/app/src/main/AndroidManifest.xml` | Android configuration and internet permission |
| Android Gradle files | Android build configuration |
| `MainActivity.kt` | Native Android activity hosting Flutter |
| Android resources | App icon and launch appearance |
| `web/index.html` | Page that loads Flutter's generated startup script |
| `web/manifest.json` | Web app name, theme colors, and installation metadata |
| Web icons | Browser and installed web app icons |
| `.gitignore` | Excludes generated builds and local tooling files from Git |
| `.metadata` | Flutter-managed project metadata |

Feature behavior is in `lib/`. Platform files host and build that code.

## 11. Tests and verification

### `test/pokemon_service_test.dart`

`MockClient` provides controlled responses without depending on the internet. Tests cover the complete list beyond 30 entries, filtering, sorting, immutable caching, retries, HTTP and GraphQL errors, malformed data, network errors, timeout, and model formatting.

### `test/pokedex_screen_test.dart`

Builds the screen in Flutter's test environment. It checks loading, cards, retry, empty results, search, sort order, counts, and completion after disposal. It also scrolls to Terapagos and searches a four-digit ID on phone and landscape layouts.

### `test/fixtures/`

`pokemon_fixtures.dart` creates small mock responses. `legendary_species.json` is a saved live response for consistent full-list tests. The running app fetches live data and does not load this fixture.

```sh
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

Analysis checks code quality, tests check behavior, and builds check compilation for the targets. This update passed analysis, all 29 tests, and both builds. A browser check also verified the live list and Terapagos image.

## 12. Useful Dart terms

| Term | Meaning |
| --- | --- |
| `final` | Assign once |
| `const` | A value that can be fixed at compile time |
| `late` | Initialize later, before reading |
| `?` after a type | The value may be null |
| `??` | Use the right value if the left is null |
| `!` after a value | Assert that the value is not null |
| `=>` | Short function syntax for a single expression |
| `..` | Cascade: perform operations while retaining the original object as the expression result |
| `@override` | Implement or replace an inherited method |
| `super.key` | Pass the widget key to the parent constructor |
| `map()` | Convert each element |
| `where()` | Keep elements matching a condition |
| `Future<T>` | One eventual value of type `T`, or an error |

## 13. Short presentation script

> “My project is an Emerald-themed Legendary Pokédex built with Flutter. It loads all species that PokéAPI classifies as Legendary and displays them in a responsive grid.
>
> “The app starts in main.dart. The model stores the species ID, name, and Legendary flag. The service sends a GraphQL query, validates the JSON response, and returns a Future containing the list.
>
> “I use a Future because loading the archive produces one result. FutureBuilder shows loading while the request is pending, an error with retry if it fails, or the grid when it succeeds.
>
> “The screen stores the Future in initState, so typing and sorting do not repeat the request. Search and sorting work on the loaded list. Each card displays the number, sprite, and name, with a fallback for images that cannot load.
>
> “The theme and reusable widgets keep the interface consistent. The tests check the service, request states, search, sorting, and scrolling.”

## 14. Common questions

**Why use a Future instead of a Stream?**

Each fetch completes once with a list or an error. A Stream suits repeated events over time, such as live messages.

**Why GraphQL?**

It lets the server return all species matching the Legendary flag in one request. The original first-30 endpoint could not provide the complete archive.

**Is the list hard-coded?**

No. Runtime data comes from the API filter. The saved list is only a test fixture.

**Why is Mew absent?**

This version follows the Legendary flag. PokéAPI records Mythical status separately. See the [species fields](https://pokeapi.co/docs/v2#pokemon-species).

**What happens without internet?**

An already-loaded list stays in memory while its service lives. A fresh load fails with a readable message and retry action. Images have a separate fallback. There is no persistent offline database.

**Does every keystroke trigger a request?**

No. The screen reuses the Future and filters its current data. The service also caches successful data.

**What API limitation should I understand?**

The GraphQL endpoint is a beta service with rate limits and possible downtime. The app handles failures and allows retry. See [PokéAPI's GraphQL documentation](https://pokeapi.co/docs/graphql).

**Why dispose resources?**

Controllers and HTTP clients hold resources. Cleanup releases them when they are no longer needed.

## Suggested demo order

1. Show the Legendary title and total count.
2. Search `rayquaza`, then clear the search.
3. Search `#1024` to demonstrate a four-digit National ID.
4. Toggle number order and A–Z.
5. Search `missingno` to show the no-results state, then clear it.
6. Scroll through the archive.
7. Explain the code: main → model → service → screen → widgets → theme → tests.
