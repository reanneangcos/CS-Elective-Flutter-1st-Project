import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/products.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'state/cart_controller.dart';
import 'theme/app_theme.dart';

void main() {
  // Flutter starts here and mounts the root widget on the screen.
  runApp(const SoleSelectApp());
}

/// The app root is stateful because changing [ThemeMode] rebuilds the entire
/// application immediately. Cart data lives in a shared [CartController].
class SoleSelectApp extends StatefulWidget {
  const SoleSelectApp({super.key});

  @override
  State<SoleSelectApp> createState() => _SoleSelectAppState();
}

class _SoleSelectAppState extends State<SoleSelectApp> {
  // These objects are created once so every route shares the same cart and
  // navigation state instead of creating a separate cart per screen.
  late final CartController _cartController;
  late final GoRouter _router;

  // ThemeMode is interaction-driven state, which is why the app root uses a
  // StatefulWidget rather than a StatelessWidget.
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _cartController = CartController();

    // GoRouter is Flutter's declarative Navigation 2.0 solution. Each route
    // maps a URL to the widget that represents that page.
    _router = GoRouter(
      initialLocation: '/',
      // The router rechecks redirects whenever the cart changes. This makes
      // the checkout guard below react to an empty or non-empty cart.
      refreshListenable: _cartController,
      routes: [
        // Opening the app goes directly to the required product-grid home.
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(
            cartController: _cartController,
            onToggleTheme: _toggleTheme,
          ),
        ),
        // Old /shop links remain valid but resolve to the catalog at root.
        GoRoute(path: '/shop', redirect: (context, state) => '/'),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            // :id is a path parameter, so every product gets a shareable URL.
            final productId = state.pathParameters['id'];
            final product = productById(productId);
            if (product == null) {
              return const _NotFoundScreen();
            }
            return ProductDetailScreen(
              product: product,
              cartController: _cartController,
            );
          },
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) =>
              CartScreen(cartController: _cartController),
        ),
        GoRoute(
          path: '/checkout',
          // A valid cart receives a generated, stable order-specific route.
          redirect: (context, state) => _cartController.isEmpty
              ? '/cart'
              : '/checkout/${_cartController.beginCheckout()}',
        ),
        GoRoute(
          path: '/checkout/:orderId',
          // Reject empty carts and stale or invented order identifiers.
          redirect: (context, state) {
            if (_cartController.isEmpty) return '/cart';
            final activeOrderId = _cartController.beginCheckout();
            return state.pathParameters['orderId'] == activeOrderId
                ? null
                : '/checkout/$activeOrderId';
          },
          builder: (context, state) => CheckoutScreen(
            cartController: _cartController,
            orderId: state.pathParameters['orderId']!,
          ),
        ),
      ],
      errorBuilder: (context, state) => const _NotFoundScreen(),
    );
  }

  void _toggleTheme() {
    // setState tells Flutter to rebuild MaterialApp with the other ThemeMode.
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  void dispose() {
    _router.dispose();
    _cartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ThemeData is applied once at MaterialApp level, so screens obtain all
    // colors and typography from Theme.of(context).
    return MaterialApp.router(
      title: 'SOLE/SELECT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    // Even the fallback page follows the requirement to use Scaffold/AppBar.
    return Scaffold(
      appBar: AppBar(title: const Text('SOLE/SELECT')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 56),
            const SizedBox(height: 16),
            Text(
              'Product not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('BACK TO SHOP'),
            ),
          ],
        ),
      ),
    );
  }
}
