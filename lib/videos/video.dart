import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth/app_user.dart';
import '../services/auth/auth_service.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Page'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('lib/images/fizik_gorsel.jpeg'),
            ElevatedButton(
              child: const Text('Fizik Videoları'),
              onPressed: () {
                Navigator.pushNamed(context, '/video_fizik');
              },
            ),
           // Image.asset('lib/images/matematik_gorsel.jpeg'),
            ElevatedButton(
              child: const Text('Matematik Videolarıı'),
              onPressed: () {
                Navigator.pushNamed(context, '/video_mat');
              },
            ),
          ],
        ),
      ),
    );
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