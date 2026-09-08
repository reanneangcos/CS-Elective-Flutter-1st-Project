import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Shared mutable state for cart items, quantities, subtotals, and totals.
///
/// ChangeNotifier implements Flutter's observer pattern: widgets listen to the
/// controller, and [notifyListeners] asks them to rebuild after every change.
class CartController extends ChangeNotifier {
  // A map prevents duplicate lines; adding the same product increases quantity.
  final Map<String, CartItem> _items = {};

  // Expose a read-only view so screens cannot mutate the map directly.
  UnmodifiableListView<CartItem> get items =>
      UnmodifiableListView(_items.values);

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity =>
      _items.values.fold(0, (total, item) => total + item.quantity);

  // fold combines every live line subtotal into the running cart total.
  double get total =>
      _items.values.fold(0, (total, item) => total + item.subtotal);

  void add(Product product) {
    final current = _items[product.id];
    _items[product.id] = current == null
        ? CartItem(product: product, quantity: 1)
        : current.copyWith(quantity: current.quantity + 1);
    notifyListeners();
  }

  void increment(String productId) {
    final current = _items[productId];
    if (current == null) return;
    _items[productId] = current.copyWith(quantity: current.quantity + 1);
    notifyListeners();
  }

  void decrement(String productId) {
    final current = _items[productId];
    if (current == null) return;
    if (current.quantity == 1) {
      // Decreasing one item removes its line instead of allowing quantity zero.
      _items.remove(productId);
    } else {
      _items[productId] = current.copyWith(quantity: current.quantity - 1);
    }
    notifyListeners();
  }

  void remove(String productId) {
    if (_items.remove(productId) != null) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
