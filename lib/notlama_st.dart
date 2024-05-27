import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GradingPage2 extends StatefulWidget {
  const GradingPage2({Key? key}) : super(key: key);

  @override
  _GradingPageState createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage2> {
  String? selectedStudent;
  String? selectedCourse;

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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid).get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  List grades = data['grades'] as List;

                  return ListView.builder(
                    itemCount: grades.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> grade = grades[index] as Map<String, dynamic>;
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text('Ders: ${grade['course']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Not: ${grade['grade']}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: DropdownButtonFormField<String>(
        hint: Text(hint),
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.cyan),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.cyan),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.cyan),
          ),
        ),
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.cyan,
      ),
    );
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
      case 'main':
        Navigator.of(context).pushNamed('/main');
        break;
    }
  }
}
