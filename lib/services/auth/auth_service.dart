import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:bitirme_flutter/services/auth/app_user.dart'; // Changed the import

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection('users');
  final studentCollection = FirebaseFirestore.instance.collection('students');
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

Future<AppUser?> addUser({
  required String name,
  required String mail,
  required String password,
  required String role,
  List<String>? studentIds,
}) async {
  try {
    // Create a new user in Firebase Authentication
    fb.UserCredential result = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: mail,
      password: password,
    );
    fb.User? fbUser = result.user;

    // Add the user's details to a new document in Firestore
    // Use the user's UID as the document ID
    if (fbUser != null) {
      await userCollection.doc(fbUser.uid).set({
        'name': name,
        'mail': mail,
        'role': role,
        'studentIds': role == 'teacher' ? studentIds ?? [] : [], // Add studentIds if the role is 'teacher'
      });

      // If the role is 'student', add the student's ID to the 'students' collection
      if (role == 'student') {
        await FirebaseFirestore.instance.collection('students').doc(fbUser.uid).set({
          'name': name,
          'mail': mail,
          'password': password, // Note: Storing passwords in Firestore is not recommended for security reasons.
          'role': role,
        });
      }

      // Sign in the user
      fb.UserCredential signInResult = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: password,
      );
      fbUser = signInResult.user;
    }

    return fbUser != null ? AppUser(id: fbUser.uid, role: role, studentIds: studentIds ?? [], name: '') : null;
  } catch (e) {
    print('Error creating user: $e');
    return null;
  }
}

Future<List<String>> getStudentIds() async {
  try {
    QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance.collection('students').get();
    return studentsSnapshot.docs.map((doc) => doc.id).toList();
  } catch (e) {
    print('Error getting student IDs: $e');
    return [];
  }
}



Future<void> updateAllTeachersStudents() async {
  try {
    // Get all student IDs
    List<String> studentIds = await getStudentIds();

    // Get all teachers
    QuerySnapshot teachersSnapshot = await userCollection.where('role', isEqualTo: 'teacher').get();
    List<DocumentSnapshot> teachers = teachersSnapshot.docs;

    // Update the 'studentIds' field for all teachers
    for (DocumentSnapshot teacher in teachers) {
      await teacher.reference.update({
        'studentIds': studentIds,
      });
    }
  } catch (e) {
    print('Error updating all teachers students: $e');
  }
}

  Future<AppUser?> getUser(String uid) async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return AppUser(
          id: uid,
          role: userData['role'],
          studentIds: List<String>.from(userData['studentIds'] ?? []),
          name: userData['name'] ?? ''
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
}