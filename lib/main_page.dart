import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  DateTime? selectedDate;
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();

  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev Takip'),
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
            ],
            onSelected: (value) {
              handleMenuSelection(value);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              calendarFormat: calendarFormat,
              focusedDay: focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                handleDateSelected(selectedDay);
              },
              firstDay: DateTime.utc(2021, 1, 1), lastDay: DateTime.utc(2025, 12, 31)
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(hintText: 'Görev Adı'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taskDescriptionController,
              decoration: const InputDecoration(hintText: 'Görev Açıklaması'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                handleAddMission();
              },
              child: const Text('Görev Ekle'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task['taskName']),
                    subtitle: Text(task['taskDescription']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      focusedDay = date;
    });
    showToast('$selectedDate');
    loadTasksForDate(selectedDate);
  }

  void handleAddMission() {
    if (selectedDate == null) {
      showToast('Lütfen bir tarih seçin');
      return;
    }

    final taskName = _taskNameController.text;
    final taskDescription = _taskDescriptionController.text;

    addTaskForDate(taskName, taskDescription);
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void addTaskForDate(String taskName, String taskDescription) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final task = {
        'userId': user.uid,
        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'taskName': taskName,
        'taskDescription': taskDescription,
      };

      FirebaseFirestore.instance.collection('tasks').add(task).then((value) {
        showToast('Görev kayıt edildi');
        loadTasksForDate(selectedDate);
      }).catchError((e) {
        showToast('Firestore hatası: $e');
      });
    }
  }

  void loadTasksForDate(DateTime? selectedDate) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && selectedDate != null) {
      FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
          .orderBy('date', descending: false)
          .get()
          .then((QuerySnapshot documents) {
        setState(() {
          tasks = [];
          for (var doc in documents.docs) {
            tasks.add(doc.data() as Map<String, dynamic>,);
          }
        });
      }).catchError((e) {
        showToast('Veri çekme hatası: $e');
      });
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
    }
  }

  List<Map<String, dynamic>> tasks = [];
}