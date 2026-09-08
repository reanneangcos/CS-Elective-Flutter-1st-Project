# SOLE/SELECT — Rubric-Based Presentation Script

**Target presentation time:** 8–10 minutes

**Recommended branch:** `PrelimExam`

**Required user flow:** Catalog → Product Detail → Add to Cart → Cart → Checkout Confirmation

This script is written to be spoken while navigating the app. Text inside quotation marks is the suggested narration. Notes under **Explain** are supporting details you can use if the instructor asks questions.

## Before presenting

1. Run the app on a phone-sized emulator, preferably 390–430 logical pixels wide.
2. Start at `/` with an empty cart and light mode enabled.
3. Keep the source code open in a second window.
4. If possible, also be ready to resize the app beyond 600 px to demonstrate the tablet grid.
5. Use the `PrelimExam` Git branch, as required by the exam document.

## Source and originality statement

The requirements used in this presentation come from the provided [Prelim Exam PDF](</Users/reannekevinangcos/Downloads/CS Elective 2 - PRELIM EXAM (2).pdf>).

SOLE/SELECT is an original, product-first sneaker catalog. It is not presented as a copy of a real retailer. The product names, descriptions, colorways, interface copy, and branding were created for this project. The eight catalog visuals were generated specifically for the project with OpenAI's image service; their embedded metadata identifies `OpenAI Media Service API`, `gpt-image`, version `2.0`, and the IPTC digital-source type `trainedAlgorithmicMedia`. They were not downloaded from sneaker brands or stock-photo sites. The original generation prompts are not stored in this repository, so do not claim that they are available.

---

# Live presentation flow

## 1. Opening and project purpose — 30 seconds

**Action:** Show the catalog home screen without touching anything yet.

**Say:**

> “Good day. This is SOLE/SELECT, a responsive Flutter sneaker shopping application. I designed it around the exact assessment flow: the user starts in the product catalog, opens a product detail page, adds an item, edits the cart, and reaches a checkout confirmation. The application uses Material widgets, declarative Navigation 2.0 through `go_router`, shared cart state, centralized light and dark themes, and layouts that adapt from phones to tablets and larger screens.”

**Explain:**

- The app opens directly to the catalog because the rubric defines the Home Screen as the product grid. A separate hero or splash page would delay the required task.
- The app is a focused shopping prototype: its strongest path is browsing, inspecting, adding, updating quantity, and reviewing the order.
- The exact routes and root app configuration are in [`lib/main.dart`](lib/main.dart).

**Rubric proof:** Required four-screen shopping flow, Navigation 2.0, light/dark themes, and responsive layouts.

---

## 2. Catalog layout and responsive grid — 1 minute

**Action:** Point to the app bar, heading, search field, category chips, result count, and product cards. Slowly scroll the catalog.

**Say:**

> “The Home Screen uses a `Scaffold` and `AppBar`, followed by one scrollable catalog. The main product area is built with `GridView.builder`, so each card is created from the product list by index. On phones it displays exactly two columns, as required. At 600 logical pixels it changes to three columns, then four at 900 and five at 1200. I use `LayoutBuilder` because it gives the actual width available to this part of the interface instead of assuming a device model.”

> “On very narrow phones, I preserve the required two columns but make each card taller. Category chips scroll horizontally instead of overflowing, page padding reduces below 360 pixels, and the content width is capped at 1440 pixels so cards do not become excessively wide on desktop.”

**Explain:**

- `_columnsFor()` implements the breakpoints: `<600 = 2`, `600–899 = 3`, `900–1199 = 4`, and `1200+ = 5`.
- `_cardRatioFor()` adjusts card height based on calculated card width.
- `CustomScrollView` owns page scrolling. The nested `GridView.builder` uses `shrinkWrap: true` and `NeverScrollableScrollPhysics` so there are not two competing vertical scroll views.
- `ConstrainedBox(maxWidth: 1440)` keeps the large-screen layout readable.
- Flutter documents `GridView.builder` as constructing its two-dimensional children on demand through an item builder. See [Flutter `GridView.builder`][F7].
- Flutter recommends making layout decisions from available space with tools such as `LayoutBuilder`; its adaptive tutorial also uses 600 px as a common phone/tablet breakpoint. See [Flutter: Build an adaptive app with LayoutBuilder][F1] and [Flutter adaptive best practices][F2].

**Code to show:** [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart), especially `_columnsFor`, `_cardRatioFor`, `LayoutBuilder`, and `GridView.builder`.

**Rubric proof:** `GridView.builder`; two phone columns; three or more tablet columns; `LayoutBuilder`; responsive behavior.

---

## 3. Product cards and information hierarchy — 45 seconds

**Action:** Point to one complete product card, then another card to show the repeated pattern.

**Say:**

> “Each grid item is a reusable `ProductCard`. It contains the required `Card`, `Image`, and `Text` widgets. The image receives the largest area, followed by the product name, colorway, and price. That order supports quick scanning: shoppers first recognize the product, then identify it, and finally compare its price.”

> “The card is a `StatelessWidget` because it only renders the `Product` passed into it. It does not own changing data. The whole card is tappable through `InkWell`, and the image includes a semantic label.”

**Explain:**

- `Image.asset(..., fit: BoxFit.contain)` shows the complete shoe without cropping it.
- `Hero` uses the product ID as a stable tag, connecting the catalog image to the detail screen.
- Text uses `maxLines` and ellipsis to prevent long names from breaking the grid.
- Baymard's product-list research identifies the thumbnail, product title/type, and price as core information people use to evaluate list items. This supports the card hierarchy; it does not mean the visual design was copied from a specific site. See [Baymard: Product Listing Information][B1].

**Code to show:** [`lib/widgets/product_card.dart`](lib/widgets/product_card.dart) and [`lib/models/product.dart`](lib/models/product.dart).

**Rubric proof:** `Card`, `Image`, `Text`, reusable widget, and appropriate `StatelessWidget` usage.

---

## 4. Search, filters, and sorting — 45 seconds

**Action:** Type part of a shoe name in Search, clear it, select a category such as COURT, then open the sort menu. Return to ALL before continuing.

**Say:**

> “Search, category filters, and sorting are supporting catalog interactions. Search matches the product name, colorway, or category. The selected chip updates the result count, and sorting can keep the featured order or arrange prices ascending or descending. These values belong to the Home Screen, so it is a `StatefulWidget` and calls `setState` when the user changes them.”

> “Filters and sorting were included because they reduce the effort of finding and comparing products as a catalog grows. Product-list filtering and sorting are established e-commerce browsing patterns documented by Baymard's research.”

**Explain:**

- `_visibleProducts` creates a new filtered list, preserving the original catalog order.
- The horizontal `SingleChildScrollView` makes all category chips reachable on a phone.
- The empty result state offers a clear-filters action rather than leaving a blank screen.
- Source for this design rationale: [Baymard research on e-commerce product lists and filtering][B2].

**Code to show:** [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart), especially `_visibleProducts`, `SearchBar`, `FilterChip`, and `PopupMenuButton`.

**Rubric proof:** Meaningful stateful interaction and responsive layout beyond the minimum requirements.

---

## 5. Theme system and dark-mode contrast — 1 minute

**Action:** Select ALL, switch to dark mode, and point out the selected lime chip and its dark text. Toggle back and forth once.

**Say:**

> “The interface uses a restrained black, white, neutral-gray, and lime palette. Neutral surfaces keep attention on the product imagery, while lime marks selected controls and primary actions. The accent is used sparingly, so it communicates state and priority rather than becoming visual noise.”

> “Both modes come from centralized `ThemeData`. The app root changes `ThemeMode`, while individual widgets obtain their colors and typography from `Theme.of(context)`. Notice that the selected filter chip remains readable in dark mode: its lime background uses `ColorScheme.secondary`, and its label uses `onSecondary`, the semantic foreground intended to be legible on that background.”

**Explain:**

- Centralized theme tokens create consistent cards, chips, buttons, search bars, text, and outlines.
- `SoleSelectApp` is stateful because switching `ThemeMode` changes the whole app.
- The selected-chip fix explicitly resolves label color to `colors.onSecondary` in the Home Screen, because relying only on the chip theme did not cover the selected `FilterChip` label correctly.
- Flutter's theming guide recommends applying a theme at `MaterialApp` and reading it with `Theme.of(context)`. See [Flutter: Use themes to share colors and font styles][F3].
- Flutter defines `onSecondary` as the color used for content displayed on `secondary`, and recommends sufficient contrast between the pair. See [Flutter `ColorScheme.onSecondary`][F4]. WCAG's general minimum for normal text is 4.5:1; this project uses semantic color pairing to support that goal, but does not claim a measured audit. See [WCAG 2.2: Contrast Minimum][W1].

**Code to show:** [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart), [`lib/main.dart`](lib/main.dart), and the selected `FilterChip` label style in [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart).

**Rubric proof:** Central `ThemeData`, light/dark themes, and a Home Screen theme toggle.

---

## 6. Product detail and Navigation 2.0 — 1 minute

**Action:** Tap **Strata One**. Point to the URL/route if it is visible, the image, name, price, description, product facts, size choices, and Add to Cart button.

**Say:**

> “Tapping a card calls `context.push` with `/product/` followed by the product ID. `go_router` reads that path parameter, finds the matching model, and builds the detail screen. This is declarative Navigation 2.0, configured once through `MaterialApp.router`. Each product therefore has a meaningful route instead of depending only on a temporary pushed widget.”

> “The detail page prominently displays the required image and price, with supporting name, description, facts, and size controls. On a phone, the image and information stack vertically. At 760 pixels and above, a `LayoutBuilder` places them side by side in a `Row`. The selected shoe size and the temporary Added state are local interactions, so this screen is stateful.”

**Explain:**

- `state.pathParameters['id']` retrieves the dynamic ID from `/product/:id`.
- An unknown product ID displays a safe not-found screen.
- `context.push` retains a back stack from catalog to detail; `context.go` is used for destination-style changes such as Cart and Checkout.
- Flutter's navigation guidance recommends a routing package such as `go_router` for advanced routing and deep links. See [Flutter navigation and routing][F5].
- The layout responds to available width, not device orientation or a hard-coded device name, matching [Flutter adaptive best practices][F2].

**Code to show:** Route definitions in [`lib/main.dart`](lib/main.dart) and layout/state in [`lib/screens/product_detail_screen.dart`](lib/screens/product_detail_screen.dart).

**Rubric proof:** Product image and price; Navigation 2.0; `StatefulWidget`; responsive `LayoutBuilder`; `Scaffold` and `AppBar`.

---

## 7. Add to Cart and shared state — 45 seconds

**Action:** Choose a size, press **ADD TO CART**, and point out the feedback and app-bar cart badge. Then press the cart icon.

**Say:**

> “When I press Add to Cart, the screen calls the shared `CartController`. If the product is new, the controller creates a cart line with quantity one; if it already exists, it increments that line. It then calls `notifyListeners`, causing listening widgets such as the cart badge and cart screen to rebuild.”

> “The cart is created once in the root app and passed to every route, so all screens observe one source of truth. This is lifted application state. The small size-selection and button-feedback values remain local to the detail page.”

**Explain:**

- `ChangeNotifier` implements the observer pattern: mutations happen in one class, followed by `notifyListeners()`.
- Keeping totals and cart mutations in the controller prevents duplicate calculation logic in screens.
- Flutter's simple state-management guide describes lifting shared state above the widgets that use it and demonstrates `ChangeNotifier` with catalog/cart-style app state. See [Flutter: Simple app state management][F6].

**Code to show:** [`lib/state/cart_controller.dart`](lib/state/cart_controller.dart), [`lib/widgets/shop_app_bar.dart`](lib/widgets/shop_app_bar.dart), and the Add to Cart handler in [`lib/screens/product_detail_screen.dart`](lib/screens/product_detail_screen.dart).

**Rubric proof:** Add to Cart action, shared interactive state, and visible cart feedback.

---

## 8. Cart quantities, subtotals, and total — 1 minute

**Action:** On Cart, point out the image, name, colorway, subtotal, quantity controls, and order summary. Press `+`, describe the changed values, then press `−` once.

**Say:**

> “The Cart Screen shows each cart item with its product information, quantity controls, and subtotal. A line subtotal is product price multiplied by quantity. The controller calculates the running total by adding all line subtotals. When I press plus or minus, the controller updates the model and notifies the screen, so the quantity, subtotal, badge, item count, and total stay synchronized.”

> “Decreasing a quantity of one removes the line rather than allowing zero or negative quantities. The close icon also removes the item. On a phone, the lines and summary form one vertical scroll view. At 900 pixels and above, the list and summary sit side by side.”

**Explain:**

- `CartItem.subtotal` owns the line formula: `product.price * quantity`.
- `CartController.total` uses `fold` to sum every subtotal.
- The screen subscribes in `initState`, handles controller replacement in `didUpdateWidget`, and removes its listener in `dispose`.
- `_CartLine`, `_QuantityButton`, and `_CartSummary` are stateless presentation components because the parent supplies their current data and callbacks.

**Code to show:** [`lib/models/cart_item.dart`](lib/models/cart_item.dart), [`lib/state/cart_controller.dart`](lib/state/cart_controller.dart), and [`lib/screens/cart_screen.dart`](lib/screens/cart_screen.dart).

**Rubric proof:** Cart items, `+`/`−` quantity controls, per-item subtotal, running total, responsive cart, `Scaffold`, and `AppBar`.

---

## 9. Checkout confirmation and route guard — 45 seconds

**Action:** Press **CHECKOUT**. Point to the item summary, each subtotal, final total, and confirmation message.

**Say:**

> “Checkout is a final read-only confirmation screen. It repeats the cart items, their quantities and subtotals, and the final total, followed by a clear confirmation message. It is a `StatelessWidget` because it presents the current controller data but does not own an editing interaction.”

> “The `/checkout` route also has a guard. If the cart is empty, `go_router` redirects to `/cart`. This enforces the rubric rule that checkout should only be accessible when there is at least one cart item, even if somebody tries to enter the URL directly.”

**Explain:**

- The controller is a `refreshListenable` for the router, so route redirects are re-evaluated when cart state changes.
- `LayoutBuilder` also adapts each purchase line to narrow widths.
- Currency output is centralized in one helper so every screen uses the same peso format.

**Code to show:** Checkout redirect in [`lib/main.dart`](lib/main.dart), UI in [`lib/screens/checkout_screen.dart`](lib/screens/checkout_screen.dart), and formatting in [`lib/utils/currency.dart`](lib/utils/currency.dart).

**Rubric proof:** Final cart summary, subtotals, final total, confirmation message, non-empty-cart restriction, `Scaffold`, and `AppBar`.

---

## 10. Closing summary — 30 seconds

**Say:**

> “To summarize, SOLE/SELECT completes the required user journey using a two-column mobile catalog and three-or-more-column tablet catalog, responsive detail and cart layouts, reusable Material components, centralized light and dark themes, stateful widgets only where interaction requires local rebuilding, stateless presentation widgets elsewhere, a shared `ChangeNotifier` cart, and `go_router` Navigation 2.0 throughout. The interface decisions support product scanning, clear action hierarchy, readable theme states, and consistent behavior across screen sizes.”

---

# Design decision defense

| Decision | Reason | Evidence/source | Where implemented |
|---|---|---|---|
| Open directly to the catalog | The assessed Home Screen is the product grid, so the shortest path exposes the primary task immediately. | Exam rubric [R1] | [`lib/main.dart`](lib/main.dart) |
| Use a two-column phone grid | This is explicitly required and gives users two products to compare per row. Taller ratios protect content on very narrow phones. | Exam rubric [R1] | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart) |
| Add 3/4/5-column breakpoints | More available width can display more products without stretching cards. Decisions are based on local constraints. | [F1], [F2] | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart) |
| Cap content width | Filling every pixel on a large display would create overly wide cards and long scan paths. | [F2] | Home, detail, and cart screens |
| Show image, name, colorway, then price | These are the attributes needed to identify and compare products in a product list. | [B1] | [`lib/widgets/product_card.dart`](lib/widgets/product_card.dart) |
| Include search/filter/sort | These controls help users narrow and reorder a growing product list. | [B2] | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart) |
| Use neutral surfaces with lime accents | Neutral surfaces prioritize product art; one accent identifies selected states and primary actions. This is a project design choice, implemented with semantic Material color roles. | [F3], [F4] | [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart) |
| Use `onSecondary` on selected lime chips | A semantic “on” color is intended for foreground content displayed over its matching container color. | [F4], [W1] | Theme and Home Screen selected-chip style |
| Centralize `ThemeData` | It keeps typography, color, card, chip, and button behavior consistent in both modes. | [F3] | [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart) |
| Use reusable cards and small widgets | Smaller components are easier to reason about and can respond to the constraints of the place where they are used. | [F2] | `lib/widgets/` and private screen widgets |
| Use `go_router` with product IDs | Declarative routes satisfy Navigation 2.0 and provide meaningful paths for products and guarded checkout. | [F5] | [`lib/main.dart`](lib/main.dart) |
| Lift cart state to the app root | Catalog/detail/cart/checkout and the badge need the same cart data. One controller prevents conflicting copies. | [F6] | [`lib/main.dart`](lib/main.dart), [`lib/state/cart_controller.dart`](lib/state/cart_controller.dart) |
| Make display-only parts stateless | They can be rebuilt from inputs and do not need to own mutable state. | Flutter widget/state design applied in this project | Product card, checkout, cart lines, summary, brand mark |
| Make interactive screens stateful | Search/filter/sort, size selection, theme mode, and cart listener updates change visible UI. | Exam rubric [R1] and Flutter state model [F6] | App root, Home, Product Detail, Cart |

## Important wording for design sources

Say that the sources **informed the rationale**, not that the interface was copied from them. For example:

> “The visual identity is original to the project. I used Flutter's official guidance for responsive layout, theming, routing, and state management, while Baymard's research supports the product-information and filtering choices.”

---

# Product image source and provenance

All eight catalog images are local 1254 × 1254 RGBA PNG files. Each contains the same embedded generation provenance described below.

| Product | Local asset | Image source |
|---|---|---|
| Strata One | `assets/products/strata_one.png` | Project-specific AI-generated image; OpenAI Media Service API / `gpt-image` v2.0 metadata |
| Flux Runner | `assets/products/flux_runner.png` | Project-specific AI-generated image; OpenAI Media Service API / `gpt-image` v2.0 metadata |
| Court 88 | `assets/products/court_88.png` | Project-specific AI-generated image; OpenAI Media Service API / `gpt-image` v2.0 metadata |
| Ridge Form | `assets/products/ridge_form.png` | Project-specific AI-generated image; OpenAI Media Service API / `gpt-image` v2.0 metadata |
| Aero Knit | `assets/products/aero_knit.png` | Project-specific AI-generated image; OpenAI Media Service API / `gpt-image` v2.0 metadata |
| Mono High | `assets/products/mono_high.png` | Project-specific AI-generated image; OpenAI Media Service API / `gpt-image` v2.0 metadata |
| Dune Trek | `assets/products/dune_trek.png` | Project-specific AI-generated image; OpenAI Media Service API / `gpt-image` v2.0 metadata |
| Harbor Court | `assets/products/harbor_court.png` | Project-specific AI-generated image; OpenAI Media Service API / `gpt-image` v2.0 metadata |

**Repository evidence:**

- `pubspec.yaml` registers `assets/products/` as the catalog asset directory.
- [`lib/data/products.dart`](lib/data/products.dart) maps the eight products to the eight files.
- Embedded image metadata identifies the software agent as `gpt-image`, version `2.0`, the generator as `OpenAI Media Service API`, and the digital source as trained algorithmic media.
- Git commit `c1e3b4abe830eda4f88ffb971351b4a3255122ea` added the product images with the project build.
- OpenAI's official model documentation describes GPT Image 2 as an image generation and editing model. See [OpenAI GPT Image 2 documentation][O1]. The web documentation explains the service; the embedded metadata is the direct provenance evidence for these particular files.
- This disclosure covers the catalog artwork. Platform launcher icons under Android, iOS, macOS, Windows, and web folders are framework/project scaffolding, not catalog product photography.

**Recommended answer if asked “Where did the images come from?”**

> “All eight shoe visuals were generated specifically for this project using OpenAI's image service. The PNG files contain embedded `gpt-image` and trained-algorithmic-media provenance metadata. They were not downloaded from real shoe brands or stock-image websites. The original prompts were not preserved in the repository, so I can document the generator and file provenance but not reproduce the exact prompts.”

Do **not** say that the images were photographed, hand-drawn, downloaded from a shoe company, or generated with stored prompts.

---

# Dart file explanation map

| File | What to explain |
|---|---|
| [`lib/main.dart`](lib/main.dart) | Entry point, root theme state, shared controller, `MaterialApp.router`, `go_router` routes, dynamic product ID, checkout guard |
| [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart) | Central light/dark `ThemeData`, `ColorScheme`, typography, button/card/chip/search styling, selected-chip foreground |
| [`lib/models/product.dart`](lib/models/product.dart) | Immutable structure for one catalog product |
| [`lib/models/cart_item.dart`](lib/models/cart_item.dart) | Product plus mutable quantity; computed line subtotal |
| [`lib/data/products.dart`](lib/data/products.dart) | Single catalog data source and product-ID lookup |
| [`lib/state/cart_controller.dart`](lib/state/cart_controller.dart) | Add, increment, decrement, remove, totals, and `notifyListeners` |
| [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart) | Search/filter/sort state, responsive breakpoints, `GridView.builder`, dark-mode chip styling |
| [`lib/screens/product_detail_screen.dart`](lib/screens/product_detail_screen.dart) | Responsive stacked/side-by-side detail layout, selected size, Add to Cart feedback |
| [`lib/screens/cart_screen.dart`](lib/screens/cart_screen.dart) | Listener lifecycle, responsive lines/summary, quantity actions, subtotal and total display |
| [`lib/screens/checkout_screen.dart`](lib/screens/checkout_screen.dart) | Stateless final order summary and confirmation message |
| [`lib/widgets/product_card.dart`](lib/widgets/product_card.dart) | Reusable stateless `Card` with image, text, price, semantics, InkWell, and Hero |
| [`lib/widgets/shop_app_bar.dart`](lib/widgets/shop_app_bar.dart) | Reusable brand mark, animated theme toggle, cart icon and badge |
| [`lib/utils/currency.dart`](lib/utils/currency.dart) | Consistent Philippine peso formatting |

---

# Rubric checklist to say or show

| Requirement | Evidence in app |
|---|---|
| Home displays all products | Root route opens the full catalog from `products.dart` |
| `GridView` or `GridView.builder` | `GridView.builder` in Home Screen |
| Two phone columns | `_columnsFor(width < 600)` returns `2` |
| Three or more tablet columns | 3 at 600, 4 at 900, 5 at 1200 |
| Product image and price on detail | Large `Image.asset` and formatted price |
| Navigation 2.0 with `go_router` | `MaterialApp.router`, `GoRouter`, and named URL paths |
| Add to Cart | Detail button calls `CartController.add` |
| Cart quantity controls | Plus and minus buttons update quantity |
| Per-item subtotal | `CartItem.subtotal` |
| Running total | `CartController.total` |
| Checkout summary | Item lines, subtotals, and final total |
| Checkout confirmation | Confirmation heading/message on checkout screen |
| Checkout only when cart is non-empty | `/checkout` redirect guard |
| `Scaffold` and `AppBar` on each screen | Catalog, Detail, Cart, Checkout, and fallback screen |
| `Card`, `Image`, and `Text` | Product cards, cart lines, checkout lines |
| Stateless widgets for static UI | ProductCard, CheckoutScreen, BrandMark, line/summary widgets |
| Stateful widgets for interaction | App root, Home, Product Detail, Cart |
| Central `ThemeData` | `AppTheme.light` and `AppTheme.dark` |
| Theme toggle on Home | App-bar toggle changes `ThemeMode` |
| `LayoutBuilder` or `MediaQuery` | `LayoutBuilder` used in Home, Detail, Cart, and Checkout |
| Required Git branch | Present from `PrelimExam` |

---

# Likely questions and concise answers

### Why keep two columns even on a very small phone?

“The rubric explicitly requires two columns on phones. I preserve that requirement and make the cards taller, reduce page padding, constrain text, and horizontally scroll the chips to avoid overflow.”

### Why use `GridView.builder` inside a `CustomScrollView`?

“The page has a heading and controls above the grid. The outer scroll view provides one continuous page, while the grid builds the required two-dimensional product layout. The inner grid is shrink-wrapped and non-scrollable, so there is only one vertical scroll owner.”

### Why is ProductCard stateless but Home Screen stateful?

“ProductCard only renders its inputs. Home owns values that change—search text, selected category, and sort order—so Home needs `setState`.”

### Why is Checkout stateless if cart data can change?

“Checkout is a read-only destination and does not own local editing state. Its data is supplied by the shared controller when the route builds. The route guard handles whether checkout is valid.”

### Why use `ChangeNotifier` instead of storing the cart in every screen?

“The badge, detail page, cart, checkout, and router guard all need the same data. One controller provides a single source of truth and notifies listeners after a mutation.”

### Why use `go_router`?

“It provides Flutter's declarative Router API, dynamic product paths, route redirects, browser-compatible URLs, and one centralized route table. That directly demonstrates Navigation 2.0.”

### How was the dark-mode filter-chip issue fixed?

“The selected chip uses the lime `secondary` color. Its text is now explicitly resolved to `onSecondary`, which is the semantic foreground for that background. Unselected labels use `onSurface`.”

### How did you make the design responsive?

“Each major screen uses `LayoutBuilder` to read available width. The catalog changes column count, the product detail changes between Column and Row, the cart changes between vertical and split layouts, and narrow components reduce padding or rearrange their children.”

### Are the product images from Nike, Adidas, or a stock website?

“No. They are project-specific AI-generated images from OpenAI's image service. Their embedded metadata records `gpt-image` and trained algorithmic media. I am disclosing that source rather than presenting them as photographs.”

### Did you preserve the exact image prompts?

“No. The repository preserves the final images and embedded generator provenance, but not the original prompt text.”

### How are prices calculated and formatted?

“The cart-line subtotal is price times quantity. The total folds over every subtotal. A shared formatter adds the peso symbol and thousands separators so the presentation is consistent.”

---

# References

## Rubric

- **[R1]** [CS Elective 2 — Prelim Exam PDF](</Users/reannekevinangcos/Downloads/CS Elective 2 - PRELIM EXAM (2).pdf>) — required screens, widgets, navigation, state, theme, responsiveness, and branch.

## Official Flutter documentation

- **[F1]** [Build an adaptive app with LayoutBuilder](https://docs.flutter.dev/learn/pathway/tutorial/adaptive-layout) — available constraints, adaptive layout, common 600 px breakpoint, and side-by-side large-screen composition.
- **[F2]** [Adaptive and responsive design best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices) — decide from available space, compose smaller widgets, and constrain content on large displays.
- **[F3]** [Use themes to share colors and font styles](https://docs.flutter.dev/cookbook/design/themes) — define theme data at the app level and retrieve it with `Theme.of(context)`.
- **[F4]** [`ColorScheme.onSecondary`](https://api.flutter.dev/flutter/material/ColorScheme/onSecondary.html) — semantic foreground color used for content on the secondary color.
- **[F5]** [Navigation and routing](https://docs.flutter.dev/ui/navigation) — Router-based navigation and the recommendation to use a routing package such as `go_router` for advanced routing.
- **[F6]** [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple) — lifting shared state, `ChangeNotifier`, listeners, and cart/catalog-style application state.
- **[F7]** [`GridView.builder`](https://api.flutter.dev/flutter/widgets/GridView/GridView.builder.html) — on-demand construction of a two-dimensional scrollable array.

## Design and accessibility research

- **[B1]** [Baymard: Essential Information to Include in Product Listings](https://baymard.com/blog/product-listing-information) — the product attributes users need while evaluating items in a list.
- **[B2]** [Baymard: E-Commerce Product Lists & Filtering UX](https://baymard.com/research/ecommerce-product-lists) — research supporting filtering, sorting, and effective product-list browsing.
- **[W1]** [W3C WCAG 2.2: Understanding Success Criterion 1.4.3, Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) — contrast guidance for readable text.

## Image-generation source

- **[O1]** [OpenAI GPT Image 2 model documentation](https://developers.openai.com/api/docs/models/gpt-image-2) — official description of OpenAI's image generation and editing model.

---

# Final presenter reminder

Do not only name widgets. For each screen, connect four ideas:

1. **What the user sees** — the component and layout.
2. **Why it was designed that way** — usability or visual hierarchy.
3. **How Flutter implements it** — widget, state, theme, route, or calculation.
4. **Which rubric item it proves** — explicitly name the requirement.

That structure demonstrates both a working app and an understanding of the code.

[F1]: https://docs.flutter.dev/learn/pathway/tutorial/adaptive-layout
[F2]: https://docs.flutter.dev/ui/adaptive-responsive/best-practices
[F3]: https://docs.flutter.dev/cookbook/design/themes
[F4]: https://api.flutter.dev/flutter/material/ColorScheme/onSecondary.html
[F5]: https://docs.flutter.dev/ui/navigation
[F6]: https://docs.flutter.dev/data-and-backend/state-mgmt/simple
[F7]: https://api.flutter.dev/flutter/widgets/GridView/GridView.builder.html
[B1]: https://baymard.com/blog/product-listing-information
[B2]: https://baymard.com/research/ecommerce-product-lists
[W1]: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
[O1]: https://developers.openai.com/api/docs/models/gpt-image-2
