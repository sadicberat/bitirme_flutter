import 'package:bitirme_flutter/services/auth/app_user.dart';
import 'package:bitirme_flutter/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final AppUser user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Çıkış Yap'),
              ),
              const PopupMenuItem(
                value: 'addNote',
                child: Text('Not Ekle'),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              initialValue: widget.user.name,
              decoration: InputDecoration(labelText: 'Name'),
              onSaved: (value) {
                // Save new name
              },
            ),
            // Repeat for other fields...
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Update user profile
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void handleMenuSelection(String value) async {
    AuthService authService = AuthService();

    AppUser? user =
        await authService.getUser(FirebaseAuth.instance.currentUser!.uid);

    switch (value) {
      case 'logout':
        FirebaseAuth.instance.signOut();
        Navigator.of(context).pushReplacementNamed('/login');
        break;
      case 'addNote':
        // Kullanıcının rolünü kontrol edin
        if (user != null && user.role == 'student') {
          // Kullanıcı bir öğrenci ise, notlama_page2.dart sayfasına yönlendirin
          Navigator.of(context).pushNamed('/addNote2');
        } else {
          // Kullanıcı bir öğretmen ise, notlama_page.dart sayfasına yönlendirin
          Navigator.of(context).pushNamed('/addNote');
        }
        break;
      case 'main':
        Navigator.of(context).pushNamed('/main');
        break;
    }
  }
}
