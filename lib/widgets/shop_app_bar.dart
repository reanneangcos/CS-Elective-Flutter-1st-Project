import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/cart_controller.dart';

/// Reusable, stateless brand title shared by every AppBar.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const logo = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text('SOLE/SELECT'),
    );

    if (onTap == null) return logo;

    return InkWell(
      key: const Key('brand-logo'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: logo,
      ),
    );
  }
}

/// Interactive theme control. The selected [ThemeMode] is stored by the
/// stateful app root so a single change rebuilds every routed screen.
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  @override
  Widget build(BuildContext context) {
    // ThemeMode lives in SoleSelectApp so it affects every route. This control
    // reads the inherited brightness and asks the parent to switch modes.
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
    // AnimatedBuilder listens only to CartController, allowing the quantity
    // badge to update without making this reusable button stateful.
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
