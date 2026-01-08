import 'package:flutter/material.dart';
import '../../data/models/ledger_entry.dart';
import '../../data/repositories/ledger_repository.dart';

class LedgerProvider extends ChangeNotifier {
  final LedgerRepository _repo;
  LedgerProvider(this._repo);

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
      items = await _repo.entries(cid);
      outstanding = await _repo.balance(cid);
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
    if (type != 'debit' && type != 'credit' && type != 'payment') {
      return 'Invalid type';
    }

    try {
      await _repo.addEntry(customerId: cid, type: type, amount: amount, note: note);
      await refresh();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> delete(String entryId) async {
    await _repo.deleteEntry(entryId);
    await refresh();
  }
}
