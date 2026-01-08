// lib/state/pos/cart_provider.dart
import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class CartLine {
  final Product product;
  final int qty;

  const CartLine({required this.product, required this.qty});

  CartLine copyWith({Product? product, int? qty}) =>
      CartLine(product: product ?? this.product, qty: qty ?? this.qty);

  double get lineTotal => qty * product.price;
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _items = [];
  List<CartLine> get items => List.unmodifiable(_items);

  // ✅ Customer info for receipt sharing
  String customerName = '';
  String customerPhone = '';
  String countryDialCode = '+92'; // default (change if needed)

  void setCustomer({
    required String name,
    required String phone,
    required String dialCode,
  }) {
    customerName = name.trim();
    customerPhone = phone.trim();
    countryDialCode = dialCode.trim();
    notifyListeners();
  }

  void clearCustomer() {
    customerName = '';
    customerPhone = '';
    countryDialCode = '+92';
    notifyListeners();
  }

  void clear() {
    _items.clear();
    clearCustomer();
    notifyListeners();
  }

  // ✅ Bill screen expects this name
  void addProduct(Product p) => add(p);

  void add(Product p) {
    final i = _items.indexWhere((x) => x.product.id == p.id);
    if (i == -1) {
      _items.add(CartLine(product: p, qty: 1));
    } else {
      _items[i] = _items[i].copyWith(qty: _items[i].qty + 1);
    }
    notifyListeners();
  }

  void inc(Product p) {
    final i = _items.indexWhere((x) => x.product.id == p.id);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(qty: _items[i].qty + 1);
    notifyListeners();
  }

  void dec(Product p) {
    final i = _items.indexWhere((x) => x.product.id == p.id);
    if (i == -1) return;
    final q = _items[i].qty - 1;
    if (q <= 0) {
      _items.removeAt(i);
    } else {
      _items[i] = _items[i].copyWith(qty: q);
    }
    notifyListeners();
  }

  void remove(Product p) {
    _items.removeWhere((x) => x.product.id == p.id);
    notifyListeners();
  }

  int get totalQty => _items.fold(0, (a, b) => a + b.qty);
  int get count => totalQty;

  double get subTotal => _items.fold(0.0, (a, b) => a + b.lineTotal);

  bool get isEmpty => _items.isEmpty;

  /// ✅ full phone for sending (dial code + number)
  String get fullPhone {
    final raw = customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final code = countryDialCode.replaceAll('+', '');
    if (raw.length < 7) return '';
    if (raw.startsWith(code)) return '+$raw';
    return '+$code$raw';
  }

}
