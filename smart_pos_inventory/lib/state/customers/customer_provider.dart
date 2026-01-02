// lib/state/customers/customer_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'customer_models.dart';
import 'customer_store.dart';

class CustomerProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  List<Customer> customers = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      customers = await CustomerStore.getAll();
    } catch (e) {
      error = e.toString();
      customers = [];
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await CustomerStore.saveAll(customers);
  }

  Future<String?> addCustomer({
    required String name,
    required String phone,
    String? address,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final c = Customer(
        id: const Uuid().v4(),
        name: name.trim(),
        phone: phone.trim(),
        address: (address == null || address.trim().isEmpty) ? null : address.trim(),
        createdAt: now,
      );

      customers.insert(0, c);
      await _save();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateCustomer(Customer c) async {
    try {
      final idx = customers.indexWhere((x) => x.id == c.id);
      if (idx == -1) return "Customer not found";
      customers[idx] = c;
      await _save();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteCustomer(String id) async {
    try {
      customers.removeWhere((x) => x.id == id);
      await _save();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  List<Customer> search(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return customers;
    return customers.where((c) {
      return c.name.toLowerCase().contains(s) || c.phone.toLowerCase().contains(s);
    }).toList();
  }
}
