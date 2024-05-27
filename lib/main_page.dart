import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:bitirme_flutter/services/auth/app_user.dart';
import 'package:bitirme_flutter/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

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
  final TextEditingController _taskDescriptionController = TextEditingController();

  List<Task> tasks = [];
  Task? selectedTask;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.cyanAccent,
          child: Text(
            'Görev Takip',
            style: GoogleFonts.lobster(
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset('lib/images/yunus.png'), // Görselinizi burada kullanın
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('Çıkış Yap')),
              const PopupMenuItem(value: 'profile', child: Text('Profil')),
              const PopupMenuItem(value: 'addNote', child: Text('Not Ekle')),
              const PopupMenuItem(value: 'video', child: Text('Video')),
            ],
            onSelected: (value) {
              handleMenuSelection(value);
            },
          ),
        ],
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
           //Lottie.asset('assets/calendar_animation.json', height: 200),
            TableCalendar(
              calendarFormat: calendarFormat,
              focusedDay: focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                hintText: 'Görev Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taskDescriptionController,
              decoration: InputDecoration(
                hintText: 'Görev Açıklaması',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedTask == null ? addTask : updateTask,
              child: Text(selectedTask == null ? 'Görev Ekle' : 'Görevi Güncelle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                tasks.sort((a, b) => DateFormat('yyyy-MM-dd')
                    .parse(a.date)
                    .compareTo(DateFormat('yyyy-MM-dd').parse(b.date)));
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      tasks[index].taskName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${tasks[index].taskDescription}\nDate: ${tasks[index].date}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (tasks[index].fileName.isNotEmpty)
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    String downloadURL = await getDownloadURL(
                                        tasks[index].userId, tasks[index].taskId, tasks[index].fileName);
                                    if (await canLaunch(downloadURL)) {
                                      await launch(downloadURL);
                                    } else {
                                      throw 'Could not launch $downloadURL';
                                    }
                                  } catch (e) {
                                    print("İndirme hatası: $e");
                                  }
                                },
                                child: const Text('Dosya İndir'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyan,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            if (tasks[index].submittedFileName.isNotEmpty)
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    String downloadURL = await getDownloadURL(
                                        tasks[index].userId, tasks[index].taskId, tasks[index].submittedFileName, isSubmitted: true);
                                    if (await canLaunch(downloadURL)) {
                                      await launch(downloadURL);
                                    } else {
                                      throw 'Could not launch $downloadURL';
                                    }
                                  } catch (e) {
                                    print("İndirme hatası: $e");
                                  }
                                },
                                child: const Text('ödev'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyan,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ElevatedButton(
                              onPressed: () => uploadFile(tasks[index].taskId, tasks[index].source == 'tasks'),
                              child: const Text('Dosya Yükle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            if (tasks[index].source == 'tasks' && tasks[index].userId == FirebaseAuth.instance.currentUser!.uid)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        selectedTask = tasks[index];
                                        _taskNameController.text = selectedTask!.taskName;
                                        _taskDescriptionController.text = selectedTask!.taskDescription;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => deleteTask(tasks[index].taskId),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void addTask() async {
    if (_taskNameController.text.isNotEmpty && _taskDescriptionController.text.isNotEmpty) {
      String taskId = FirebaseFirestore.instance.collection('tasks').doc().id;

      Task newTask = Task(
        userId: FirebaseAuth.instance.currentUser!.uid,
        taskId: taskId,
        date: DateFormat('yyyy-MM-dd').format(selectedDate!),
        taskName: _taskNameController.text,
        taskDescription: _taskDescriptionController.text,
        fileName: "",
        submittedFileName: "",
        source: 'tasks',
      );

      final tasksRef = FirebaseFirestore.instance.collection('tasks');
      await tasksRef.doc(newTask.taskId).set(newTask.toMap());

      await fetchTasks(); // Tüm görevleri yeniden yükle

      setState(() {
        selectedTask = null;
      });

      _taskNameController.clear();
      _taskDescriptionController.clear();
    }
  }

  void updateTask() async {
    if (_taskNameController.text.isNotEmpty && _taskDescriptionController.text.isNotEmpty && selectedTask != null) {
      Task updatedTask = Task(
        userId: selectedTask!.userId,
        taskId: selectedTask!.taskId,
        date: DateFormat('yyyy-MM-dd').format(selectedDate!),
        taskName: _taskNameController.text,
        taskDescription: _taskDescriptionController.text,
        fileName: selectedTask!.fileName,
        submittedFileName: selectedTask!.submittedFileName,
        source: selectedTask!.source,
      );

      final tasksRef = FirebaseFirestore.instance.collection('tasks');
      await tasksRef.doc(updatedTask.taskId).set(updatedTask.toMap());

      await fetchTasks(); // Tüm görevleri yeniden yükle

      setState(() {
        selectedTask = null;
      });

      _taskNameController.clear();
      _taskDescriptionController.clear();
    }
  }

  void deleteTask(String taskId) async {
    final tasksRef = FirebaseFirestore.instance.collection('tasks');
    await tasksRef.doc(taskId).delete();

    await fetchTasks(); // Tüm görevleri yeniden yükle

    setState(() {});
  }

  Future<void> fetchTasks() async {
    final tasksRef = FirebaseFirestore.instance.collection('tasks');
    final querySnapshot = await tasksRef
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    tasks.clear();

    for (final doc in querySnapshot.docs) {
      Task task = Task.fromMap(doc.data());
      task.source = 'tasks';
      tasks.add(task);
    }

    final studentTasksRef = FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid);
    final studentDocSnapshot = await studentTasksRef.get();

    if (studentDocSnapshot.exists) {
      final data = studentDocSnapshot.data();
      if (data != null && data.containsKey('tasks')) {
        for (final task in data['tasks']) {
          Task studentTask = Task.fromMap(task);
          studentTask.source = 'students';
          tasks.add(studentTask);
        }
      }
    }

    setState(() {});
  }

  void handleMenuSelection(String value) async {
    switch (value) {
      case 'logout':
        await AuthService().signOut();
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        break;
      case 'profile':
        Navigator.of(context).pushNamed('/profile');
        break;
      case 'addNote':
        AppUser? user = await AuthService().getUser(FirebaseAuth.instance.currentUser!.uid);
        if (user != null && user.role == 'student') {
          Navigator.of(context).pushNamed('/addNote2');
        } else {
          Navigator.of(context).pushNamed('/addNote');
        }
        break;
      case 'video':
        Navigator.of(context).pushNamed('/videoPage');
        break;
    }
  }

  Future<String> getDownloadURL(String userId, String taskId, String fileName, {bool isSubmitted = false}) async {
    try {
      String path = isSubmitted
          ? 'uploads/submissions/$userId/$taskId/$fileName'
          : 'uploads/$userId/$taskId/$fileName';
      String downloadURL = await FirebaseStorage.instance.ref(path).getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("URL alma hatası: $e");
      throw e;
    }
  }

  Future<void> uploadFile(String taskId, bool isTask) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      try {
        String fileName = file.name;
        String filePath;

        if (isTask) {
          filePath = 'uploads/${FirebaseAuth.instance.currentUser!.uid}/$taskId/$fileName';
        } else {
          filePath = 'uploads/submissions/${FirebaseAuth.instance.currentUser!.uid}/$taskId/$fileName';
        }

        if (file.bytes != null) {
          await FirebaseStorage.instance.ref(filePath).putData(file.bytes!);
        } else if (file.path != null) {
          await FirebaseStorage.instance.ref(filePath).putFile(File(file.path!));
        }

        if (isTask) {
          // tasks koleksiyonundaki görev için güncelleme
          final tasksRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);
          await tasksRef.update({'fileName': fileName});
        } else {
          // students koleksiyonundaki görev için güncelleme
          final tasksRef = FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid);
          final docSnapshot = await tasksRef.get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data();
            if (data != null && data.containsKey('tasks')) {
              List<dynamic> tasks = List.from(data['tasks']);
              int taskIndex = tasks.indexWhere((task) => task['taskId'] == taskId);
              if (taskIndex != -1) {
                tasks[taskIndex]['submittedFileName'] = fileName;
                tasks[taskIndex]['isSubmitted'] = true;
                await tasksRef.update({'tasks': tasks});
              }
            }
          }
        }

        fetchTasks();
        print("Dosya başarıyla yüklendi.");
      } catch (e) {
        print("Yükleme hatası: $e");
      }
    } else {
      print("Dosya seçilmedi.");
    }
  }
}

class Task {
  final String userId;
  final String taskId;
  final String date;
  final String taskName;
  final String taskDescription;
  final String fileName;
  final String submittedFileName;
  final bool isSubmitted;
  String source;

  Task({
    required this.userId,
    required this.taskId,
    required this.date,
    required this.taskName,
    required this.taskDescription,
    required this.fileName,
    this.submittedFileName = "",
    this.isSubmitted = false,
    this.source = 'tasks',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'taskId': taskId,
      'date': date,
      'taskName': taskName,
      'taskDescription': taskDescription,
      'fileName': fileName,
      'submittedFileName': submittedFileName,
      'isSubmitted': isSubmitted,
      'source': source,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      userId: map['userId'] ?? '',
      taskId: map['taskId'] ?? '',
      date: map['date'] ?? '',
      taskName: map['taskName'] ?? '',
      taskDescription: map['taskDescription'] ?? '',
      fileName: map['fileName'] ?? '',
      submittedFileName: map['submittedFileName'] ?? '',
      isSubmitted: map['isSubmitted'] ?? false,
      source: map['source'] ?? 'tasks',
    );
  }
}
