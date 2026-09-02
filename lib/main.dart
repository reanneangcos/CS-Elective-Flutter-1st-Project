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
  late final CartController _cartController;
  late final GoRouter _router;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _cartController = CartController();
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _cartController,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(
            cartController: _cartController,
            onToggleTheme: _toggleTheme,
          ),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
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
          redirect: (context, state) =>
              _cartController.isEmpty ? '/cart' : null,
          builder: (context, state) =>
              CheckoutScreen(cartController: _cartController),
        ),
      ],
      errorBuilder: (context, state) => const _NotFoundScreen(),
    );
  }

  void _toggleTheme() {
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
