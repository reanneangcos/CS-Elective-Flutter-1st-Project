# SOLE/SELECT

SOLE/SELECT is a responsive Flutter sneaker shop browser created for the
CS Elective 2 prelim exam. Its monochrome, product-first visual direction is
inspired by modern sneaker marketplaces while all branding, copy, and product
images are original to this project.

## Required user flow

`Home → Product Detail → Add to Cart → Cart → Checkout Confirmation`

## Exam requirements demonstrated

- `GridView.builder` catalog with eight original products
- `LayoutBuilder` responsive grid: 2 columns on phones and 3-5 columns on
  tablet and desktop widths
- Navigation 2.0 with `go_router` and a `/product/:id` route
- `Scaffold` and `AppBar` on every screen
- Centralized light and dark `ThemeData`
- A home-screen theme toggle that updates the whole app immediately
- Working product search, category filters, and price sorting
- Stateless product cards for static product information
- Stateful app theme, product selection/add state, and cart screen
- Live cart quantity, line subtotal, and order-total calculations
- Checkout guard that redirects an empty cart back to the cart screen
- Final confirmation containing items, quantities, subtotals, and total

## Run the project

```bash
flutter pub get
flutter run
```

Run the checks with:

```bash
flutter analyze
flutter test
```

## State explanation for presentation

- `ProductCard` is stateless because its product data does not change after it
  is built.
- `ProductDetailScreen` is stateful because the selected size and add-to-cart
  button state change after interaction.
- `CartScreen` is stateful because it listens for quantity and total changes.
- `SoleSelectApp` is stateful because switching `ThemeMode` rebuilds the entire
  application in light or dark mode.
- `CartController` is the single shared source of truth for cart items and
  totals across routes.

## Presentation walkthrough

- `main.dart`: app entry point, shared cart creation, Navigation 2.0 routes,
  guarded checkout route, and global light/dark `ThemeMode` state.
- `theme/app_theme.dart`: centralized color schemes, typography, cards,
  buttons, chips, search, menus, dividers, and snackbar styling.
- `models/` and `data/products.dart`: immutable product/cart data and the eight
  products displayed by the catalog.
- `state/cart_controller.dart`: add, increment, decrement, remove, subtotal,
  total, and `ChangeNotifier` updates.
- `screens/home_screen.dart` and `widgets/product_card.dart`: responsive
  `GridView.builder`, search/filter/sort state, and stateless product cards.
- `screens/product_detail_screen.dart`: responsive product details, selected
  size, and stateful add-to-cart/view-cart button.
- `screens/cart_screen.dart`: stateful cart listener, quantity controls,
  subtotals, running total, and mobile/tablet layouts.
- `screens/checkout_screen.dart`: stateless confirmation and final item,
  subtotal, and total summary.
- `widgets/shop_app_bar.dart` and `utils/currency.dart`: shared app-bar controls,
  live cart badge, theme toggle, and reusable peso formatting.
- `test/`: verifies the required flow, two phone columns, three tablet columns,
  responsive rendering, live totals, theme switching, and checkout protection.

## Project structure

```text
lib/
├── data/       Product catalog
├── models/     Product and cart item models
├── screens/    Home, product detail, cart, and checkout
├── state/      Shared cart controller
├── theme/      Centralized light/dark design system
├── utils/      Currency formatting
└── widgets/    Reusable product and AppBar widgets
```
