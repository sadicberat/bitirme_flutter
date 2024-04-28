import 'package:bitirme_flutter/services/auth/app_user.dart';
import 'package:bitirme_flutter/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('GradingPage2 build called');
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          String currentUserName = data['name'];
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
            body: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                String student = students[index];
                return ListTile(
                  title: Text(student),
                  trailing: student == currentUserName ? Text(grades[student] ?? 'Not bilgisi yok') : null,
                );
              },
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<String?> getCurrentUserGrade() async {
    // Mevcut kullanıcının uid'sini alın
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Kullanıcının belgesini alın
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('students').doc(uid).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    // Not bilgisini döndürün
    return userData['grade'];
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