import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/cart_controller.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('SOLE/SELECT');
  }
}

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Use light mode' : 'Use dark mode',
      onPressed: widget.onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) =>
            RotationTransition(turns: animation, child: child),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}

class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key, required this.cartController});

  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartController,
      builder: (context, child) {
        final count = cartController.totalQuantity;
        return IconButton(
          tooltip: 'Open cart',
          onPressed: () => context.push('/cart'),
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text(count.toString()),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
        );
      },
    );
  }
}
