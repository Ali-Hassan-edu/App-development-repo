import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirePaths {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String uid() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw Exception('Not logged in');
    return u.uid;
  }

  static CollectionReference<Map<String, dynamic>> _col(String name) {
    return _db.collection('users').doc(uid()).collection(name);
  }

  static CollectionReference<Map<String, dynamic>> products() => _col('products');
  static CollectionReference<Map<String, dynamic>> customers() => _col('customers');
  static CollectionReference<Map<String, dynamic>> sales() => _col('sales');
  static CollectionReference<Map<String, dynamic>> categories() => _col('categories');

  static CollectionReference<Map<String, dynamic>> ledger(String customerId) =>
      customers().doc(customerId).collection('ledger');
}
