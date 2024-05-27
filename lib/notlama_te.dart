import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart'; // DateFormat sınıfı için eklendi
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class GradingPage extends StatefulWidget {
  @override
  _GradingPageState createState() => _GradingPageState();
}

class _GradingPageState extends State<GradingPage> {
  String? selectedStudent;
  String? selectedCourse;
  String? selectedGrade;
  DateTime? selectedDate;
  DateTime? dueDate;

  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  Map<String, String> students = {};
  List<String> courses = ['Course 1', 'Course 2', 'Course 3'];
  List<Task> tasks = [];
  Task? selectedTask;

  bool isLoadingTasks = false;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlama Sayfası mı'),
        backgroundColor: Colors.cyan,
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
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildDropdownButton(
              hint: 'Öğrenci seçiniz',
              value: selectedStudent,
              items: students.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key, // The value is the student ID
                  child: Text(entry.value), // The displayed text is the student name
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStudent = newValue; // The selected student ID is stored
                  tasks.clear(); // Clear tasks when a new student is selected
                  isLoadingTasks = true; // Show loading indicator
                });
                fetchTasks(newValue!).then((_) {
                  setState(() {
                    isLoadingTasks = false; // Hide loading indicator
                  });
                });
              },
            ),
            const SizedBox(height: 12),
            if (selectedStudent != null) ...[
              _buildDropdownButton(
                hint: 'Select Course',
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
              _buildGradeInput(),
              const SizedBox(height: 12),
              _buildDateButton('Tarih Seçiniz', () async {
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
              }),
              const SizedBox(height: 16),
              _buildDueDateInput(),
              _buildTextField(taskNameController, 'Görev Adı'),
              _buildTextField(taskDescriptionController, 'Görev Açıklaması'),
              const SizedBox(height: 16),
              _buildAddTaskButton(),
              if (selectedDate != null)
                Text('Selected date: ${selectedDate.toString()}'),
              const SizedBox(height: 16),
              isLoadingTasks ? CircularProgressIndicator() : _buildTaskList(),
            ],
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
    return DropdownButton<String>(
      hint: Text(hint),
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      style: TextStyle(color: Colors.black, fontSize: 16),
      dropdownColor: Colors.white,
      iconEnabledColor: Colors.cyan,
    );
  }

  Widget _buildGradeInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Not giriniz',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.cyan),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.cyan),
              ),
            ),
            onChanged: (String value) {
              selectedGrade = value;
            },
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            if (selectedStudent != null && selectedCourse != null && selectedGrade != null) {
              addGradeToStudent(selectedStudent!, selectedCourse!, selectedGrade!);
            }
          },
          child: const Text('Not Ekle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDueDateInput() {
    return TextField(
      controller: dueDateController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Son Teslim Tarihi Seçin',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.cyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.cyan),
        ),
      ),
      onTap: () async {
        try {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            setState(() {
              dueDate = picked;
              dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
            });
          }
        } catch (e) {
          print('DatePicker error: $e');
        }
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.cyan),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.cyan),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return ElevatedButton(
      onPressed: () {
        if (selectedStudent != null && selectedDate != null && dueDate != null) {
          addTask(
            selectedStudent!,
            selectedDate!,
            taskNameController.text,
            taskDescriptionController.text,
            dueDate!,
          );
        }
      },
      child: Text('Görev Ekle'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Flexible(
      fit: FlexFit.loose,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          tasks.sort((a, b) => DateFormat('yyyy-MM-dd').parse(a.date).compareTo(DateFormat('yyyy-MM-dd').parse(b.date)));
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(tasks[index].taskName, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${tasks[index].taskDescription}\nDate: ${tasks[index].date}'),
                  const SizedBox(height: 8),
                  if (DateTime.now().isAfter(DateFormat('yyyy-MM-dd').parse(tasks[index].dueDate)))
                    Text('Son teslim tarihi geçti.', style: TextStyle(color: Colors.red)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            String downloadURL = await getDownloadURL(tasks[index].userId, tasks[index].taskId, tasks[index].fileName);
                            if (await canLaunch(downloadURL)) {
                              await launch(downloadURL);
                            } else {
                              throw 'Could not launch $downloadURL';
                            }
                          } catch (e) {
                            print("İndirme hatası: $e");
                          }
                        },
                        child: const Text('Dosya İndir (Öğretmen)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (tasks[index].submittedFileName.isNotEmpty)
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              String downloadURL = await getDownloadURL(tasks[index].userId, tasks[index].taskId, tasks[index].submittedFileName, isSubmitted: true);
                              if (await canLaunch(downloadURL)) {
                                await launch(downloadURL);
                              } else {
                                throw 'Could not launch $downloadURL';
                              }
                            } catch (e) {
                              print("İndirme hatası: $e");
                            }
                          },
                          child: const Text('Dosya İndir (Öğrenci)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ElevatedButton(
                        onPressed: DateTime.now().isAfter(DateFormat('yyyy-MM-dd').parse(tasks[index].dueDate)) ? null : () => uploadFile(tasks[index].taskId),
                        child: Text(tasks[index].isSubmitted ? 'Teslim Edildi' : 'Dosya Yükle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (tasks[index].userId == FirebaseAuth.instance.currentUser!.uid)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  selectedTask = tasks[index];
                                  taskNameController.text = selectedTask!.taskName;
                                  taskDescriptionController.text = selectedTask!.taskDescription;
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
    );
  }

  Future<void> addTask(String studentId, DateTime date, String taskName, String taskDescription, DateTime dueDate) async {
    String taskId = FirebaseFirestore.instance.collection('tasks').doc().id;

    Task newTask = Task(
      userId: studentId,
      taskId: taskId,
      date: DateFormat('yyyy-MM-dd').format(date),
      taskName: taskName,
      taskDescription: taskDescription,
      dueDate: DateFormat('yyyy-MM-dd').format(dueDate),
      fileName: "",
      submittedFileName: "",
    );

    final tasksRef = FirebaseFirestore.instance.collection('students').doc(studentId);
    await tasksRef.update({
      'tasks': FieldValue.arrayUnion([newTask.toMap()])
    });

    fetchTasks(studentId);

    setState(() {
      selectedTask = null;
    });

    taskNameController.clear();
    taskDescriptionController.clear();
    dueDateController.clear();
  }

  void deleteTask(String taskId) async {
    final tasksRef = FirebaseFirestore.instance.collection('students').doc(selectedStudent);
    final docSnapshot = await tasksRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('tasks')) {
        List<dynamic> tasks = List.from(data['tasks']);
        tasks.removeWhere((task) => task['taskId'] == taskId);

        await tasksRef.update({'tasks': tasks});
      }
    }

    // Firebase Storage'daki dosyayı sil
    await FirebaseStorage.instance
        .ref('uploads/$selectedStudent/$taskId/')
        .listAll()
        .then((result) {
      result.items.forEach((file) {
        file.delete();
      });
    });

    fetchTasks(selectedStudent!);

    setState(() {});
  }

  Future<void> fetchTasks(String studentId) async {
    final tasksRef = FirebaseFirestore.instance.collection('students').doc(studentId);
    final docSnapshot = await tasksRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('tasks')) {
        tasks.clear();
        for (final task in data['tasks']) {
          tasks.add(Task.fromMap(task));
        }
        setState(() {});
      }
    }
  }

  Future<void> fetchStudents() async {
    final studentsRef = FirebaseFirestore.instance.collection('students');
    final querySnapshot = await studentsRef.get();

    for (final doc in querySnapshot.docs) {
      students[doc.id] = doc['name'];
    }

    setState(() {});
  }

  Future<void> addGradeToStudent(String studentId, String course, String grade) async {
    final studentRef = FirebaseFirestore.instance.collection('students').doc(studentId);

    Map<String, dynamic> gradeData = {
      'course': course,
      'grade': grade,
    };

    final docSnapshot = await studentRef.get();

    if (docSnapshot.exists) {
      final docData = docSnapshot.data();
      if (docData != null) {
        if (docData.containsKey('grades')) {
          List grades = docData['grades'];
          int index = grades.indexWhere((grade) => grade['course'] == course);

          if (index != -1) {
            grades[index]['grade'] = grade;
          } else {
            grades.add(gradeData);
          }

          await studentRef.update({'grades': grades});
        } else {
          await studentRef.set(
            {
              'grades': [gradeData],
            },
            SetOptions(merge: true),
          );
        }
      }
    } else {
      await studentRef.set({
        'grades': [gradeData],
      });
    }
  }

  Future<String> getDownloadURL(String userId, String taskId, String fileName, {bool isSubmitted = false}) async {
    try {
      String path = isSubmitted
          ? 'uploads/submissions/$userId/$taskId/$fileName'
          : 'uploads/$userId/$taskId/$fileName';
      String downloadURL = await FirebaseStorage.instance
          .ref(path)
          .getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("URL alma hatası: $e");
      throw e;
    }
  }

  Future<void> uploadFile(String taskId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      try {
        String fileName = file.name;

        // Dosya yolu her durumda aynı olacak.
        String filePath = 'uploads/$selectedStudent/$taskId/$fileName';

        if (file.bytes != null) {
          await FirebaseStorage.instance.ref(filePath).putData(file.bytes!);
        } else if (file.path != null) {
          await FirebaseStorage.instance.ref(filePath).putFile(File(file.path!));
        }

        final tasksRef = FirebaseFirestore.instance.collection('students').doc(selectedStudent);
        final docSnapshot = await tasksRef.get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data.containsKey('tasks')) {
            List<dynamic> tasks = List.from(data['tasks']);
            int taskIndex = tasks.indexWhere((task) => task['taskId'] == taskId);
            if (taskIndex != -1) {
              tasks[taskIndex]['fileName'] = fileName; // Her yükleme bu alanı günceller.
              await tasksRef.update({'tasks': tasks});
            }
          }
        }

        fetchTasks(selectedStudent!);
        print("Dosya başarıyla yüklendi.");
      } catch (e) {
        print("Yükleme hatası: $e");
      }
    } else {
      print("Dosya seçilmedi.");
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
      case 'main':
        Navigator.of(context).pushNamed('/main');
        break;
    }
  }
}

class Task {
  final String userId;
  final String taskId;
  final String date;
  final String taskName;
  final String taskDescription;
  final String dueDate;
  final String fileName;
  final String submittedFileName;
  final bool isSubmitted;

  Task({
    required this.userId,
    required this.taskId,
    required this.date,
    required this.taskName,
    required this.taskDescription,
    required this.dueDate,
    required this.fileName,
    this.submittedFileName = "",
    this.isSubmitted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'taskId': taskId,
      'date': date,
      'taskName': taskName,
      'taskDescription': taskDescription,
      'dueDate': dueDate,
      'fileName': fileName,
      'submittedFileName': submittedFileName,
      'isSubmitted': isSubmitted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      userId: map['userId'] ?? '',
      taskId: map['taskId'] ?? '',
      date: map['date'] ?? '',
      taskName: map['taskName'] ?? '',
      taskDescription: map['taskDescription'] ?? '',
      dueDate: map['dueDate'] ?? '',
      fileName: map['fileName'] ?? '',
      submittedFileName: map['submittedFileName'] ?? '',
      isSubmitted: map['isSubmitted'] ?? false,
    );
  }
}
