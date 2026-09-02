import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartController extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  UnmodifiableListView<CartItem> get items =>
      UnmodifiableListView(_items.values);

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity =>
      _items.values.fold(0, (total, item) => total + item.quantity);

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
