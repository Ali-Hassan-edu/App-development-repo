import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../core/firestore_paths.dart';
import 'customer_models.dart';

class CustomerProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  List<Customer> customers = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final snap = await FirePaths.customers()
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      customers = snap.docs.map((d) {
        final data = d.data();
        // Ensure id exists
        final withId = {...data, 'id': d.id};
        return Customer.fromJson(withId);
      }).toList();
    } catch (e) {
      error = e.toString();
      customers = [];
    }

    loading = false;
    notifyListeners();
  }

  Customer? getById(String id) {
    try {
      return customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<String?> addCustomer({
    required String name,
    required String phone,
    String? address,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = const Uuid().v4();

      final data = {
        'id': id,
        'name': name.trim(),
        'phone': phone.trim(),
        'address': (address == null || address.trim().isEmpty) ? null : address.trim(),
        'createdAt': now,
        'updatedAt': now,
      };

      await FirePaths.customers().doc(id).set(data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateCustomer(Customer c) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await FirePaths.customers().doc(c.id).update({
        ...c.toJson(),
        'updatedAt': now,
      });
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteCustomer(String id) async {
    try {
      await FirePaths.customers().doc(id).delete();
      await load();
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
