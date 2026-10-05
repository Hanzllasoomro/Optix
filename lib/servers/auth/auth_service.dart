import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{

  //instance of auth and firestore
  final FirebaseAuth _auth= FirebaseAuth.instance;
  final FirebaseFirestore _firestore= FirebaseFirestore.instance;

  // get current user
  User? get getCurrentUser => _auth.currentUser;

  //sign in
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try{

      // sign in user
      UserCredential userCredential= await _auth.signInWithEmailAndPassword(
          email: email,
          password: password);


      final user = userCredential.user;
      if (user != null) {
        await ensureUserDocumentExists(user); // Ensures Firestore data & expenses
      }

      return userCredential;
    } on FirebaseAuthException catch(e) {
      throw Exception(e.code);
    }
  }
  /// ✅ Ensure user document & subcollections exist
  Future<void> ensureUserDocumentExists(User user) async {
    final docRef = _firestore.collection('Users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Create user document
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'shopName': '',
        'contactNumber': '',
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update missing fields
      await docRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
        'shopName': doc.data()?['shopName'] ?? '',
        'contactNumber': doc.data()?['contactNumber'] ?? '',
        'address': doc.data()?['address'] ?? '',
      });
    }
  }

  //sign out
  Future<void> signOut() async{
    return await _auth.signOut();
  }
//errors

}