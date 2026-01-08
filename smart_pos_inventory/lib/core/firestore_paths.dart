import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirePaths {
  static String uid() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw Exception('Not logged in');
    return u.uid;
  }

  static CollectionReference<Map<String, dynamic>> products() =>
      FirebaseFirestore.instance.collection('users').doc(uid()).collection('products');

  static CollectionReference<Map<String, dynamic>> customers() =>
      FirebaseFirestore.instance.collection('users').doc(uid()).collection('customers');

  static CollectionReference<Map<String, dynamic>> sales() =>
      FirebaseFirestore.instance.collection('users').doc(uid()).collection('sales');

  static CollectionReference<Map<String, dynamic>> ledger(String customerId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid())
          .collection('customers')
          .doc(customerId)
          .collection('ledger');
}
