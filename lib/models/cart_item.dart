import 'product.dart';

/// One purchasable cart line: a product in one selected US size.
///
/// Size is part of the identity. Two pairs of SS-P001 in size 7 belong to one
/// line with quantity two, while SS-P001 in sizes 7 and 8 are separate lines.
class CartItem {
  const CartItem({
    required this.product,
    required this.size,
    required this.quantity,
  });

  final Product product;
  final int size;
  final int quantity;

  /// Stable identifier used by the cart map and quantity-control callbacks.
  String get lineId => '${product.id}-US$size';

  /// A computed property keeps each line subtotal synchronized with quantity.
  double get subtotal => product.price * quantity;

  /// Creates a replacement value because cart items are treated as immutable.
  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      size: size,
      quantity: quantity ?? this.quantity,
    );
  }
}
