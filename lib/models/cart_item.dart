import 'product.dart';

/// Combines an immutable [Product] with the quantity currently in the cart.
class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  /// A computed property keeps each line subtotal synchronized with quantity.
  double get subtotal => product.price * quantity;

  /// Creates a replacement value because cart items are treated as immutable.
  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}
