import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/firestore_paths.dart';
import '../../data/models/ledger_entry.dart';

class LedgerProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  String? activeCustomerId;
  List<LedgerEntry> items = [];
  double outstanding = 0;

  Future<void> openCustomer(String customerId) async {
    activeCustomerId = customerId;
    await refresh();
  }

  Future<void> refresh() async {
    final cid = activeCustomerId;
    if (cid == null) return;

    loading = true;
    error = null;
    notifyListeners();

    try {
      final snap = await FirePaths.ledger(cid)
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      items = snap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        return LedgerEntry.fromMap({
          ...data,
          'id': d.id,
          'customerId': cid,
        });
      }).toList();

      double bal = 0;
      for (final e in items) {
        if (e.type == 'debit') bal += e.amount;
        if (e.type == 'credit' || e.type == 'payment') bal -= e.amount;
      }
      outstanding = bal;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<String?> add({
    required String type,
    required double amount,
    String? note,
  }) async {
    final cid = activeCustomerId;
    if (cid == null) return 'No customer selected';
    if (amount <= 0) return 'Amount must be greater than 0';
    if (!LedgerEntry.isValidType(type)) return 'Invalid type';

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = const Uuid().v4();

      final entry = LedgerEntry(
        id: id,
        customerId: cid,
        type: type,
        amount: amount,
        note: (note == null || note.trim().isEmpty) ? null : note.trim(),
        createdAt: now,
        synced: 1,
      );

      await FirePaths.ledger(cid).doc(id).set(entry.toMap());
      await refresh();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> delete(String entryId) async {
    final cid = activeCustomerId;
    if (cid == null) return;

    await FirePaths.ledger(cid).doc(entryId).delete();
    await refresh();
  }
}
