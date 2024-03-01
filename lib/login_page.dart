import 'package:bitirme_flutter/firebase_options.dart';
import 'package:bitirme_flutter/main_page.dart';
import 'package:bitirme_flutter/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "services/auth/auth_service.dart";


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(const MaterialApp(
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Formu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Burada giriş yapma işlemini gerçekleştirebilirsiniz.
                // Örneğin, Firebase Authentication kullanarak giriş yapabilirsiniz.
                _login();


              },
              child: const Text('Giriş Yap'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const RegisterPage() ));

              },
              child: const Text('kayıt ol'),
            ),
          ],
        ),
      ),
    );
  }



  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      print('Giriş yapıldı - Kullanıcı UID: ${user?.uid}');
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MainActivity()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Kullanıcı bulunamadı');
      } else if (e.code == 'wrong-password') {
        print('Hatalı şifre');
      } else {
        print('Giriş yaparken bir hata oluştu: $e');
      }
    } catch (e) {
      print('Giriş yaparken bir hata oluştu(catch): $e');
    }
  }



}


