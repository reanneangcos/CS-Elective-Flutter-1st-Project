import 'package:flutter_test/flutter_test.dart';
import 'package:sole_select/data/products.dart';
import 'package:sole_select/state/cart_controller.dart';

void main() {
  test('cart quantities and running total update live', () {
    final cart = CartController();
    final product = products.first;

    cart.add(product);
    expect(cart.totalQuantity, 1);
    expect(cart.total, product.price);

    cart.increment(product.id);
    expect(cart.totalQuantity, 2);
    expect(cart.total, product.price * 2);

    cart.decrement(product.id);
    expect(cart.totalQuantity, 1);

    cart.decrement(product.id);
    expect(cart.isEmpty, isTrue);
  });
}
