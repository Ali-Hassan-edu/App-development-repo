import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class CartLine {
  final Product product;
  final int qty;

  /// ✅ editable runtime price (can differ from product.price)
  final double unitPrice;

  const CartLine({
    required this.product,
    required this.qty,
    required this.unitPrice,
  });

  CartLine copyWith({Product? product, int? qty, double? unitPrice}) => CartLine(
    product: product ?? this.product,
    qty: qty ?? this.qty,
    unitPrice: unitPrice ?? this.unitPrice,
  );

  double get lineTotal => qty * unitPrice;
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _items = [];
  List<CartLine> get items => List.unmodifiable(_items);

  // ✅ Customer info
  String customerName = '';
  String customerPhone = '';
  String countryDialCode = '+92';

  // ✅ Discount (₹) and tax (%)
  double _discount = 0.0; // rupees
  double _taxPercent = 0.0; // percent

  double get discount => _discount;
  double get taxPercent => _taxPercent;

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

  void setDiscount(double value) {
    _discount = value < 0 ? 0 : value;
    notifyListeners();
  }

  void setTaxPercent(double value) {
    _taxPercent = value < 0 ? 0 : value;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _discount = 0.0;
    _taxPercent = 0.0;
    clearCustomer();
    notifyListeners();
  }

  // ✅ Bill screen expects this name
  void addProduct(Product p) => add(p);

  void add(Product p) {
    final i = _items.indexWhere((x) => x.product.id == p.id);
    if (i == -1) {
      _items.add(CartLine(product: p, qty: 1, unitPrice: p.price));
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

  /// ✅ update line runtime price
  void updateLinePrice(String productId, double newPrice) {
    if (newPrice <= 0) return;
    final i = _items.indexWhere((x) => x.product.id == productId);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(unitPrice: newPrice);
    notifyListeners();
  }

  int get totalQty => _items.fold(0, (a, b) => a + b.qty);
  int get count => totalQty;

  double get subTotal => _items.fold(0.0, (a, b) => a + b.lineTotal);

  /// ✅ computed amounts
  double get discountAmount {
    if (_discount <= 0) return 0.0;
    return _discount > subTotal ? subTotal : _discount;
  }

  double get taxAmount {
    final base = subTotal - discountAmount;
    if (base <= 0) return 0.0;
    if (_taxPercent <= 0) return 0.0;
    return base * (_taxPercent / 100.0);
  }

  double get grandTotal => (subTotal - discountAmount) + taxAmount;

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
