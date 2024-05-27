import 'dart:typed_data';

import 'package:bitirme_flutter/services/auth/app_user.dart';
import 'package:bitirme_flutter/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;
  Map<String, dynamic>? userData;
  String? profileImageUrl;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();
        if (mounted) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>?;
            profileImageUrl = userData?['profileImageUrl'];
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = 'Kullanıcı verileri alınırken bir hata oluştu: $e';
        });
      }
    }
  }

  Future<void> uploadProfileImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.bytes != null) {
      Uint8List fileBytes = result.files.single.bytes!;
      String fileName = '${user!.uid}.png';
      try {
        await _storage.ref('profile_images/$fileName').putData(fileBytes);
        String downloadUrl =
            await _storage.ref('profile_images/$fileName').getDownloadURL();
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .update({'profileImageUrl': downloadUrl});
        if (mounted) {
          setState(() {
            profileImageUrl = downloadUrl;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            errorMessage = 'Profil resmi yüklenirken bir hata oluştu: $e';
          });
        }
      }
    }
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
        AppUser? user =
            await AuthService().getUser(FirebaseAuth.instance.currentUser!.uid);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Sayfası', style: GoogleFonts.lobster()),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Profili düzenleme fonksiyonu
            },
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : buildProfileContent(),
    );
  }

  Widget buildProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
            child:
                profileImageUrl == null ? Icon(Icons.person, size: 50) : null,
          ),
          if (profileImageUrl != null)
            Image.network(
              profileImageUrl!,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                }
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Center(child: Icon(Icons.error, color: Colors.red));
              },
            ),
          TextButton(
            onPressed: uploadProfileImage,
            child: Text('Profil Fotoğrafını Güncelle'),
          ),
          SizedBox(height: 16),
          Text(
            userData!['name'] ?? 'Adınız',
            style: GoogleFonts.pacifico(fontSize: 24, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            user!.email ?? 'Email',
            style: GoogleFonts.roboto(fontSize: 18, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text(
            userData!['role'] ?? 'Rol',
            style: GoogleFonts.roboto(fontSize: 18, color: Colors.black54),
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),
          Text(
            'Görevler',
            style: GoogleFonts.lobster(fontSize: 24, color: Colors.black),
          ),
          SizedBox(height: 8),
          buildTaskList(),
        ],
      ),
    );
  }

  Widget buildTaskList() {
    if (userData!['tasks'] == null || userData!['tasks'].isEmpty) {
      return Text('Görev bulunmamaktadır.');
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: userData!['tasks'].length,
      itemBuilder: (context, index) {
        var task = userData!['tasks'][index];
        return ListTile(
          title: Text(
            task['taskName'],
            style: GoogleFonts.roboto(fontSize: 18),
          ),
          subtitle: Text(
            'Son Tarih: ${task['dueDate']}',
            style: GoogleFonts.roboto(fontSize: 14),
          ),
          trailing: IconButton(
            icon: Icon(Icons.download),
            onPressed: () => downloadFile(task['filePath']),
          ),
        );
      },
    );
  }

  Future<void> downloadFile(String filePath) async {
    try {
      String downloadURL = await _storage.ref(filePath).getDownloadURL();
      if (await canLaunch(downloadURL)) {
        await launch(downloadURL);
      } else {
        throw 'Could not launch $downloadURL';
      }
    } catch (e) {
      print("İndirme hatası: $e");
    }
  }
}
