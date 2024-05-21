import 'package:bitirme_flutter/login_page.dart';
import 'package:bitirme_flutter/main_page.dart';
import 'package:bitirme_flutter/profil_page.dart';
import 'package:bitirme_flutter/services/auth/app_user.dart';
import 'package:bitirme_flutter/services/auth/auth_service.dart';
import 'package:bitirme_flutter/videos/video.dart';
import 'package:bitirme_flutter/videos/video_fizik.dart';
import 'package:bitirme_flutter/videos/video_mat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'notlama_st.dart';
import 'notlama_te.dart';
import 'signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/main': (context) => const MainActivity(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/profile': (context) => FutureBuilder<AppUser?>(
          future: authService.getUser(FirebaseAuth.instance.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return ProfilePage(user: snapshot.data!);
              } else {
                return const CircularProgressIndicator();
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        '/addNote': (context) => GradingPage(),
        '/addNote2': (context) => const GradingPage2(),
        '/videoPage': (context) => const VideoPage(),
        '/video_fizik': (context) => VideoFizikPage(),
        '/video_mat': (context) => const VideoMatPage(),
      },
    );
  }
}
