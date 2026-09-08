import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Shared mutable state for cart items, quantities, subtotals, and totals.
///
/// ChangeNotifier implements Flutter's observer pattern: widgets listen to the
/// controller, and [notifyListeners] asks them to rebuild after every change.
class CartController extends ChangeNotifier {
  CartController({DateTime Function()? now}) : _now = now ?? DateTime.now;

  // A line is unique by both product and size. This keeps different sizes of
  // one shoe separate while combining repeated additions of the same size.
  final Map<String, CartItem> _items = {};
  final DateTime Function() _now;
  String? _activeOrderId;
  int _orderSequence = 0;

  // Expose a read-only view so screens cannot mutate the map directly.
  UnmodifiableListView<CartItem> get items =>
      UnmodifiableListView(_items.values);

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity =>
      _items.values.fold(0, (total, item) => total + item.quantity);

  // fold combines every live line subtotal into the running cart total.
  double get total =>
      _items.values.fold(0, (total, item) => total + item.subtotal);

  String? get activeOrderId => _activeOrderId;

  static String lineIdFor(Product product, int size) => '${product.id}-US$size';

  void add(Product product, int size) {
    if (!product.sizes.contains(size)) {
      throw ArgumentError.value(size, 'size', 'Unavailable for ${product.id}');
    }

    final lineId = lineIdFor(product, size);
    final current = _items[lineId];
    _items[lineId] = current == null
        ? CartItem(product: product, size: size, quantity: 1)
        : current.copyWith(quantity: current.quantity + 1);
    _cartChanged();
  }

  void increment(String lineId) {
    final current = _items[lineId];
    if (current == null) return;
    _items[lineId] = current.copyWith(quantity: current.quantity + 1);
    _cartChanged();
  }

  void decrement(String lineId) {
    final current = _items[lineId];
    if (current == null) return;
    if (current.quantity == 1) {
      // Decreasing one item removes its line instead of allowing quantity zero.
      _items.remove(lineId);
    } else {
      _items[lineId] = current.copyWith(quantity: current.quantity - 1);
    }
    _cartChanged();
  }

  void remove(String lineId) {
    if (_items.remove(lineId) != null) _cartChanged();
  }

  /// Creates one order ID per unchanged cart and reuses it while checkout is
  /// displayed. Any later cart edit invalidates it so a revised order gets a
  /// new identity.
  String beginCheckout() {
    if (isEmpty) throw StateError('Cannot create an order from an empty cart.');
    final existing = _activeOrderId;
    if (existing != null) return existing;

    final time = _now();
    _orderSequence += 1;
    final date =
        '${time.year.toString().padLeft(4, '0')}'
        '${time.month.toString().padLeft(2, '0')}'
        '${time.day.toString().padLeft(2, '0')}';
    final clock =
        '${time.hour.toString().padLeft(2, '0')}'
        '${time.minute.toString().padLeft(2, '0')}'
        '${time.second.toString().padLeft(2, '0')}';
    _activeOrderId =
        'SS-O-$date-$clock-${_orderSequence.toString().padLeft(2, '0')}';
    return _activeOrderId!;
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    _activeOrderId = null;
    notifyListeners();
  }

  void _cartChanged() {
    _activeOrderId = null;
    notifyListeners();
  }
}
