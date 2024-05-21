import 'package:bitirme_flutter/services/auth/app_user.dart';
import 'package:bitirme_flutter/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({Key? key}) : super(key: key);

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  DateTime? selectedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();


  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

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
              const PopupMenuItem(
                value: 'video',
                child: Text('Video'),
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
                  addTask();
                  setState(() {
                    selectedDate = selectedDay;
                    focusedDay = focusedDay;
                  });
                },
                firstDay: DateTime.utc(2021, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31)),
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
              onPressed: addTask,
              child: const Text('Görev Ekle'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  tasks.sort((a, b) => DateFormat('yyyy-MM-dd')
                      .parse(a.date)
                      .compareTo(DateFormat('yyyy-MM-dd').parse(b.date)));
                  return Card(
                    child: ListTile(
                      title: Text(tasks[index].taskName),
                      subtitle: Text(
                          '${tasks[index].taskDescription}\nDate: ${tasks[index].date}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addTask() async {
    if (_taskNameController.text.isNotEmpty &&
        _taskDescriptionController.text.isNotEmpty) {
      Task newTask = Task(
        userId: FirebaseAuth.instance.currentUser!.uid,
        date: DateFormat('yyyy-MM-dd').format(selectedDate!),
        taskName: _taskNameController.text,
        taskDescription: _taskDescriptionController.text,
      );

      // Add the new task to Firestore
      final tasksRef = FirebaseFirestore.instance.collection('tasks');
      await tasksRef.add(newTask.toMap());

      // Fetch tasks from Firestore
      final querySnapshot = await tasksRef
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Clear the current tasks list
      tasks.clear();

      // Add fetched tasks to the tasks list
      for (final doc in querySnapshot.docs) {
        tasks.add(Task.fromMap(doc.data()));
      }

      setState(() {});

      _taskNameController.clear();
      _taskDescriptionController.clear();
    }
  }

  Future<void> fetchTasks() async {
    final tasksRef = FirebaseFirestore.instance.collection('tasks');
    final querySnapshot = await tasksRef
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    tasks.clear();

    for (final doc in querySnapshot.docs) {
      tasks.add(Task.fromMap(doc.data()));
    }

    setState(() {});
  }

void handleMenuSelection(String value) async {

  AuthService authService = AuthService();

  AppUser? user = await authService.getUser(FirebaseAuth.instance.currentUser!.uid);

  switch (value) {
    case 'logout':
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
      break;
    case 'profile':
      Navigator.of(context).pushNamed('/profile');
      break;
    case 'addNote':
    // Kullanıcının rolünü kontrol edin
      if (user != null && user.role == 'student') {
        // Kullanıcı bir öğrenci ise, notlama_st.dart sayfasına yönlendirin
        Navigator.of(context).pushNamed('/addNote2');
      } else {
        // Kullanıcı bir öğretmen ise, notlama_te.dart sayfasına yönlendirin
        Navigator.of(context).pushNamed('/addNote');
      }
      break;
    case 'video':
      Navigator.of(context).pushNamed('/videoPage');
      break;
  }
}
}

class Task {
  final String userId;
  final String date;
  final String taskName;
  final String taskDescription;

  Task({
    required this.userId,
    required this.date,
    required this.taskName,
    required this.taskDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'taskName': taskName,
      'taskDescription': taskDescription,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      taskName: map['taskName'] ?? '',
      taskDescription: map['taskDescription'] ?? '',
    );
  }
}
