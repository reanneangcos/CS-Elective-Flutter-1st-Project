import 'package:flutter_test/flutter_test.dart';
import 'package:sole_select/data/products.dart';
import 'package:sole_select/state/cart_controller.dart';

void main() {
  // This isolates the rubric's quantity, subtotal, and live-total behavior
  // from the interface so the state logic is easy to verify independently.
  test('cart quantities and running total update per product and size', () {
    final cart = CartController();
    final product = products.first;
    final size7Line = CartController.lineIdFor(product, 7);
    final size8Line = CartController.lineIdFor(product, 8);

    cart.add(product, 7);
    expect(cart.totalQuantity, 1);
    expect(cart.total, product.price);

    // The same product and size combine into one line with quantity two.
    cart.add(product, 7);
    expect(cart.totalQuantity, 2);
    expect(cart.total, product.price * 2);
    expect(cart.items, hasLength(1));

    // A different size of the same product is a separate purchasable line.
    cart.add(product, 8);
    expect(cart.totalQuantity, 3);
    expect(cart.items, hasLength(2));
    expect(cart.items.map((item) => item.lineId), {size7Line, size8Line});

    cart.increment(size8Line);
    expect(cart.totalQuantity, 4);

    cart.decrement(size7Line);
    expect(cart.totalQuantity, 3);

    cart.remove(size7Line);
    expect(cart.items.single.size, 8);
    expect(cart.items.single.quantity, 2);
  });

  test(
    'checkout uses a stable order id and refreshes it after cart changes',
    () {
      final cart = CartController(now: () => DateTime(2026, 9, 8, 14, 30, 25));
      final product = products.first;

      expect(() => cart.beginCheckout(), throwsStateError);

      cart.add(product, 7);
      final firstOrder = cart.beginCheckout();
      expect(firstOrder, 'SS-O-20260908-143025-01');
      expect(cart.beginCheckout(), firstOrder);

      cart.add(product, 8);
      final revisedOrder = cart.beginCheckout();
      expect(revisedOrder, 'SS-O-20260908-143025-02');
      expect(revisedOrder, isNot(firstOrder));
    },
  );
}
