import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
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
        title: Text('Login Formu'),
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
              decoration: InputDecoration(
                labelText: 'E-posta',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Burada giriş yapma işlemini gerçekleştirebilirsiniz.
                // Örneğin, Firebase Authentication kullanarak giriş yapabilirsiniz.
                _login();
              },
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() {
    // Bu kısımda giriş yapma işlemini gerçekleştirebilirsiniz.
    // Örneğin, Firebase Authentication kullanarak giriş yapabilirsiniz.
    String email = _emailController.text;
    String password = _passwordController.text;

    // Giriş işlemleri burada yapılacak.
    print('Giriş yapıldı - E-posta: $email, Şifre: $password');
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}
