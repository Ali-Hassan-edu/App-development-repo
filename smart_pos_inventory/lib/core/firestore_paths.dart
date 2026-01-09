import 'package:cloud_firestore/cloud_firestore.dart';

class FirePaths {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> products() =>
      _db.collection('products');

  static CollectionReference<Map<String, dynamic>> customers() =>
      _db.collection('customers');

  static CollectionReference<Map<String, dynamic>> sales() =>
      _db.collection('sales');

  static CollectionReference<Map<String, dynamic>> categories() =>
      _db.collection('categories');

  /// ✅ Ledger is stored under customer subcollection:
  /// customers/{customerId}/ledger/{entryId}
  static CollectionReference<Map<String, dynamic>> ledger(String customerId) =>
      customers().doc(customerId).collection('ledger');
}
