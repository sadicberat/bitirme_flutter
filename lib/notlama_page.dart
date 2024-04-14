import 'package:bitirme_flutter/services/auth/app_user.dart';
import 'package:bitirme_flutter/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GradingPage extends StatefulWidget {
  const GradingPage({Key? key}) : super(key: key);

  @override
  _GradingPageState createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage> {
  // Öğrenci listesi ve her öğrencinin notu
  List<String> students = [];
  Map<String, String> grades = {};

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

@override
Widget build(BuildContext context) {
    print('GradingPage build called');
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid).get(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        Map<String, dynamic> data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
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
                trailing: student == FirebaseAuth.instance.currentUser!.uid ? Text(data['grade']) : DropdownButton<String>(
                  value: grades[student],
                  items: <String>['A', 'B', 'C', 'D', 'F'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      grades[student] = newValue!;
                      updateGrades(student, newValue!);
                    });
                  },
                ),
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

Future<void> fetchStudents() async {
  AuthService authService = AuthService();

  // Öğretmenin uid'sini alın
  String teacherUid = FirebaseAuth.instance.currentUser!.uid;
  AppUser? teacher = await authService.getUser(teacherUid);
  if (teacher != null) {
    // Her öğrenci için
    for (String studentId in teacher.studentIds) {
      // Öğrencinin belgesini alın
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance.collection('students').doc(studentId).get();
      Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;

      // Öğrencinin adını alın ve öğrenci listesine ekleyin
      String studentName = studentData['name'];
      students.add(studentName);

      // Öğrencinin notunu alın, eğer not bilgisi yoksa varsayılan bir değer atayın
      grades[studentName] = studentData['grade'] ?? 'A';
    }
    // setState'i asenkron işlemler tamamlandıktan sonra çağırın
    setState(() {});
  }
}

  Future<void> updateGrades(String studentName, String grade) async {
    try {
      // Öğrencinin belgesini alın
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('students').where('name', isEqualTo: studentName).get();
      DocumentSnapshot studentDoc = querySnapshot.docs.first;
      // Notu güncelleyin
      await studentDoc.reference.update({
        'grade': grade,
      });
    } catch (e) {
      print('Error updating grade: $e');
    }
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