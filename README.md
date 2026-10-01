# Emerald Pokédex — Legendary Archive

A Flutter Pokédex for the CS Elective 2 async activity. It shows every species that PokéAPI marks as Legendary, across all generations, in an Emerald-inspired interface.

The current live query returns **71 Legendary species**. The app reads the total from the response; it has no 30-entry cap or fixed list of IDs. Each species appears once, using its National Pokédex number. Mythical Pokémon and alternate forms do not appear as additional entries.

## Run

Requires Flutter with Dart 3.12.2 or newer and an internet connection for PokéAPI and images.

```sh
flutter pub get
flutter run -d chrome
```

For Android, start an emulator or connect a device, then run `flutter run`. Internet permission is included in the main Android manifest.

## Code explanation guide

Read [CODE_GUIDE.md](CODE_GUIDE.md) for the data flow, an explanation of each source file and function, a short presentation script, and answers to common questions.

## Features

- All Legendary species, with their name, sprite, and National Pokédex number.
- Search by name or number, including `#384` and four-digit IDs such as `1024`.
- Toggle between National Pokédex order and alphabetical order.
- Responsive, scrollable grid with live visible/total counts.
- Loading, error, empty-response, and no-search-results states with appropriate actions.
- In-memory caching; typing and sorting do not send additional data requests.
- Emerald sprites for generations I–III and general PokéAPI sprites for later species.

This edition expands the activity's original first-30 list to all Legendary species. It keeps the model/service/screen/widget structure and the `FutureBuilder` approach. Cards remain a grid without a detail route.

## Data source

The service sends one HTTP POST to `https://graphql.pokeapi.co/v1beta2`:

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

The species filter comes from PokéAPI's `is_legendary` classification. PokéAPI records `is_mythical` separately. See the [species documentation](https://pokeapi.co/docs/v2#pokemon-species).

GraphQL lets the server filter the species in one request. Its endpoint is a beta service with a documented rate limit of 100 calls per hour per IP and brief scheduled downtime. Successful lists are cached for the service's lifetime; restarting the app fetches again. See [PokéAPI's GraphQL documentation](https://pokeapi.co/docs/graphql).

The service applies a 15-second timeout, validates the response, handles both HTTP failures and GraphQL errors, and rejects partial responses with query errors. Empty results and failures remain retryable.

## Why a Future?

`fetchPokemon()` produces one eventual list or an error, represented by `Future<List<Pokemon>>`. The screen stores that Future in `initState()`, and `FutureBuilder` updates the interface when it finishes. A retry replaces the stored Future. A Stream would suit a source that emits repeated updates over time.

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
  fixtures/
    pokemon_fixtures.dart
    legendary_species.json
assets/fonts/
CODE_GUIDE.md
```

## Checks

```sh
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

Tests use mock HTTP responses and a saved live species response. They cover the complete list, Legendary filtering, caching, validation, HTTP/GraphQL failures, timeout, retry, search, sorting, dynamic counts, disposal, and scrolling on phone and landscape layouts.

## Repository

[View the `pokedex-act` branch](https://github.com/reanneangcos/CS-Elective-Flutter-1st-Project/tree/pokedex-act).

## Sources and assets

- [PokéAPI](https://pokeapi.co/docs/graphql) supplies the species data.
- [PokéAPI sprites](https://github.com/PokeAPI/sprites) supplies images. National species IDs map to sprite filenames; older species use the Emerald directory.
- [Flutter FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html) renders the asynchronous result.
- Silkscreen and Space Mono are bundled from [Google Fonts](https://github.com/google/fonts), with their SIL Open Font License files in `assets/fonts/`.

This is an educational fan project. Pokémon names and sprites belong to their respective owners.
