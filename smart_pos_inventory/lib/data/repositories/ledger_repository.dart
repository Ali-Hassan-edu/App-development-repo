import '../local/dao/ledger_dao.dart';
import '../models/ledger_entry.dart';

class LedgerRepository {
  final LedgerDao dao;
  LedgerRepository(this.dao);

  String _makeId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'led_$now';
  }

  Future<List<LedgerEntry>> entries(String customerId) => dao.getByCustomer(customerId);

  Future<double> balance(String customerId) => dao.getBalance(customerId);

  Future<void> addEntry({
    required String customerId,
    required String type,
    required double amount,
    String? note,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final entry = LedgerEntry(
      id: _makeId(),
      customerId: customerId,
      type: type,
      amount: amount,
      note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
      createdAt: now,
      synced: 0,
    );

    await dao.insert(entry);
  }

  Future<void> deleteEntry(String id) => dao.deleteById(id);
}
