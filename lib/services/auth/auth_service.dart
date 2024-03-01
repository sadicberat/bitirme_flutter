import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final userCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> addUser({required String name, required String mail, required String password}) async {

  await userCollection.doc().set({
    'name': name,
    'mail': mail,
    'password': password,
  });

  UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: mail,
    password: password,
  );
  User? user = result.user;
  return user;
  }

  Future<void> addUser2(String email, String password) async {
    try {
      // E-posta adresi kullanımda mı kontrol et
      var existingUser = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (existingUser.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use by another account.',
        );
      }

      // Kullanıcıyı kaydet
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Diğer işlemler...
    } catch (error) {
      print("Kullanıcı ekleme hatası: $error");
      throw error;
    }
  }




}



// Path: lib/services/auth/auth_service.dart