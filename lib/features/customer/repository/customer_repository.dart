import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shelfit/features/customer/model/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //!Add customer
  Future<void> addCustomer(CustomerModel customer)async{
    try{
      final uid = _auth.currentUser?.uid;
      if(uid == null) throw Exception('User not found');

      await _firestore.collection('customers').add({
        ...customer.toMap(),
        'uid': uid,
      });
    }catch(e){
      rethrow;
    }
  }

  //!Fetch
  Future<List<CustomerModel>> fetchCustomers()async{
    try{
      final uid = _auth.currentUser?.uid;
      if(uid == null) throw Exception("User not logged in");

      final snapshot = await _firestore
            .collection('customers')
            .where('uid', isEqualTo: uid)
            .get();

      return snapshot.docs
              .map((doc)=>CustomerModel.fromMap(doc.data(), doc.id)).toList();
    }catch(e){
      rethrow;
    }
  }


  //! Edit customer
  Future<void> editCustomer(CustomerModel customer) async {
    try {
      await _firestore
          .collection('customers')
          .doc(customer.id)
          .update(customer.toMap());
    } catch (e) {
      rethrow;
    }
  }

  //! Delete
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection('customers').doc(customerId).delete();
    } catch (e) {
      rethrow;
    }
  }


}
