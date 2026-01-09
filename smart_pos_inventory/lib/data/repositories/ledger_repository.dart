import '../../core/firestore_paths.dart';
import '../models/ledger_entry.dart';

class LedgerRepository {
  Future<List<LedgerEntry>> entries(String customerId) async {
    final snap = await FirePaths.ledger(customerId)
        .orderBy('createdAt', descending: true)
        .limit(500)
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      final merged = {
        ...data,
        'id': d.id,
        'customerId': customerId,
      };
      return LedgerEntry.fromMap(merged);
    }).toList();
  }

  Future<double> balance(String customerId) async {
    final snap = await FirePaths.ledger(customerId).get();

    double bal = 0.0;
    for (final d in snap.docs) {
      final m = d.data();
      final type = (m['type'] ?? '').toString();
      final amt = (m['amount'] as num?)?.toDouble() ?? 0.0;

      if (type == 'debit') bal += amt;
      if (type == 'credit' || type == 'payment') bal -= amt;
    }
    return bal;
  }

  Future<void> addEntry({
    required String customerId,
    required String type,
    required double amount,
    String? note,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final doc = FirePaths.ledger(customerId).doc();

    await doc.set({
      'id': doc.id,
      'customerId': customerId,
      'type': type,
      'amount': amount,
      'note': (note == null || note.trim().isEmpty) ? null : note.trim(),
      'createdAt': now,
      'synced': 1,
    });
  }

  Future<void> deleteEntry(String customerId, String entryId) async {
    await FirePaths.ledger(customerId).doc(entryId).delete();
  }
}
