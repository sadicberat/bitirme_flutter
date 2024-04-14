import 'package:bitirme_flutter/services/auth/app_user.dart';
import 'package:bitirme_flutter/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _role = 'student';
  List<String> _roles = ['student', 'teacher'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'İsim'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _role,
              items: _roles.map((String role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _role = value.toString();
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _nameController.text.isNotEmpty) {
                  try {
                    AppUser? user = await AuthService().addUser(
                      name: _nameController.text,
                      mail: _emailController.text,
                      password: _passwordController.text,
                      role: _role,
                    );
                    if (_role == 'teacher') {
                      AuthService authService = AuthService(); // AuthService sınıfının bir örneğini oluşturun
                      List<String> studentIds = await authService.getStudentIds(); // getStudentIds fonksiyonunu çağırın ve sonucunu bekleyin
                      await AuthService().updateAllTeachersStudents(); // updateAllTeachersStudents fonksiyonunu çağırın ve sonucunu bekleyin
                    }
                    if (user != null) {
                      // Navigate to main_page.dart
                      Navigator.pushNamed(context, '/main');
                    }
                  } catch (e) {
                    // Handle the error
                    print('Registration error: $e');
                  }
                } else {
                  // Handle the case where the text fields are empty
                  print('Please fill in all fields');
                }
              },
              child: const Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}