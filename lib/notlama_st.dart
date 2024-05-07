import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GradingPage2 extends StatefulWidget {
  const GradingPage2({Key? key}) : super(key: key);

  @override
  _GradingPageState createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage2> {
  // Öğrenci listesi ve her öğrencinin notu
  List<String> students = [];
  Map<String, String> grades = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlama Sayfası'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Çıkış Yap'),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profil'),
              ),
              const PopupMenuItem(
                value: 'addNote',
                child: Text('Not Ekle'),
              ),
              const PopupMenuItem(
                value: 'main',
                child: Text('Ana Sayfa'),
              ),
            ],
            onSelected: (value) {
              handleMenuSelection(value);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return FutureBuilder<String?>(
                future: getGradeFromStudent(document.id, 'courseName'),
                // Replace 'courseName' with the actual course name
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(data['name']),
                      subtitle: Text('Not: Loading...'),
                    );
                  } else {
                    String? grade = snapshot.data;
                    return ListTile(
                      title: Text(data['name']),
                      subtitle: Text('Not: ${grade ?? 'N/A'}'),
                    );
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<String?> getGradeFromStudent(String studentId, String course) async {
    final studentRef =
        FirebaseFirestore.instance.collection('students').doc(studentId);

    // Get the document
    final docSnapshot = await studentRef.get();

    // Check if the document exists
    if (docSnapshot.exists) {
      // Get the document data
      final docData = docSnapshot.data();

      // Check if the document data is not null
      if (docData != null) {
        // Check if the 'grades' field exists
        if (docData.containsKey('grades')) {
          // Get the grades
          List grades = docData['grades'];

          // Check if a grade for the course exists
          int index = grades.indexWhere((grade) => grade['course'] == course);

          if (index != -1) {
            // If a grade for the course exists, return it
            return grades[index]['grade'];
          }
        }
      }
    }

    // If the document doesn't exist, or the 'grades' field doesn't exist, or a grade for the course doesn't exist, return null
    return null;
  }

  void handleMenuSelection(String value) {
    switch (value) {
      case 'logout':
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacementNamed('/login');
        break;
      case 'profile':
        Navigator.of(context).pushNamed('/profile');
        break;
      case 'addNote':
        Navigator.of(context).pushNamed('/addNote');
        break;
      case 'main':
        Navigator.of(context).pushNamed('/main');
        break;
    }
  }
}