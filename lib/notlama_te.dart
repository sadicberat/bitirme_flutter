import 'package:bitirme_flutter/notlama_st.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GradingPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<GradingPage> {
  String? selectedStudent;
  String? selectedCourse;
  String? selectedGrade;
  DateTime? selectedDate;

  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();

  Map<String, String> students = {};
  List<String> courses = ['Course 1', 'Course 2', 'Course 3'];
  Map<String, int> grades = {};

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

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
          children: <Widget>[
            DropdownButton<String>(
              hint: Text('Select Student'),
              value: selectedStudent,
              items: students.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key, // The value is the student ID
                  child: Text(
                      entry.value), // The displayed text is the student name
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStudent =
                      newValue; // The selected student ID is stored
                });
              },
            ),
            SizedBox(height: 12),
            if (selectedStudent != null)
              Column(
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Course'),
                    value: selectedCourse,
                    items: courses.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCourse = newValue;
                      });
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Not giriniz'),
                          onChanged: (String value) {
                            selectedGrade = value;
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedStudent != null &&
                              selectedCourse != null &&
                              selectedGrade != null) {
                            addGradeToStudent(selectedStudent!, selectedCourse!,
                                selectedGrade!);
                          }
                        },
                        child: const Text('Not Ekle'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000, 1),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != selectedDate)
                          setState(() {
                            selectedDate = picked;
                          });
                      } catch (e) {
                        print('DatePicker error: $e');
                      }
                    },
                    child: Text('Select date'),
                  ),
                  TextField(
                    controller: taskNameController,
                    decoration: InputDecoration(hintText: 'Görev Adı'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: taskDescriptionController,
                    decoration: InputDecoration(hintText: 'Görev Açıklaması'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedStudent != null && selectedDate != null) {
                        addTask(
                            selectedStudent!,
                            selectedDate!,
                            taskNameController.text,
                            taskDescriptionController.text);
                      }
                    },
                    child: Text('Görev Ekle'),
                  ),
                  if (selectedDate != null)
                    Text('Selected date: ${selectedDate.toString()}'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> addTask(String studentId, DateTime date, String taskName,
    String taskDescription) async {
  final studentRef = FirebaseFirestore.instance.collection('students').doc(studentId);

  Map<String, dynamic> task = {
    'date': date.toIso8601String(), // Convert DateTime to String
    'taskName': taskName,
    'taskDescription': taskDescription,
  };

  // Get the document
  final docSnapshot = await studentRef.get();

  // Check if the document exists
  if (docSnapshot.exists) {
    // Get the document data
    final docData = docSnapshot.data();

    // Check if the document data is not null
    if (docData != null) {
      // Check if the 'tasks' field exists
      if (docData.containsKey('tasks')) {
        // Get the tasks
        List tasks = docData['tasks'];

        // Add the new task
        tasks.add(task);

        // Update the 'tasks' field
        await studentRef.update({'tasks': tasks});
      } else {
        // If the 'tasks' field doesn't exist, create it and add the task
        await studentRef.set({
          'tasks': [task],
        }, SetOptions(merge: true)); // merge: true prevents overwriting existing data
      }
    }
  } else {
    // If the document doesn't exist, create it and add the 'tasks' field with the task
    await studentRef.set({
      'tasks': [task],
    });
  }
}

  Future<void> addGradeToStudent(
      String studentId, String course, String grade) async {
    final studentRef =
        FirebaseFirestore.instance.collection('students').doc(studentId);

    Map<String, dynamic> gradeData = {
      'course': course,
      'grade': grade,
    };

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

          // Check if a grade for the course already exists
          int index = grades.indexWhere((grade) => grade['course'] == course);

          if (index != -1) {
            // If a grade for the course already exists, update it
            grades[index]['grade'] = grade;
          } else {
            // If a grade for the course doesn't exist, add it
            grades.add(gradeData);
          }

          // Update the 'grades' field
          await studentRef.update({'grades': grades});
        } else {
          // If the 'grades' field doesn't exist, create it and add the grade data
          await studentRef.set(
              {
                'grades': [gradeData],
              },
              SetOptions(
                  merge:
                      true)); // merge: true prevents overwriting existing data
        }
      }
    } else {
      // If the document doesn't exist, create it and add the 'grades' field with the grade data
      await studentRef.set({
        'grades': [gradeData],
      });
    }
  }

  Future<void> fetchStudents() async {
    final studentsRef = FirebaseFirestore.instance.collection('students');
    final querySnapshot = await studentsRef.get();

    for (final doc in querySnapshot.docs) {
      students[doc.id] = doc[
          'name']; // Assuming the student name is stored in the 'name' field
    }

    setState(() {});
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
