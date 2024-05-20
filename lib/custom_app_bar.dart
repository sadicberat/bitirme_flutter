import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
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
            handleMenuSelection(value, context);
          },
        ),
      ],
    );
  }

  void handleMenuSelection(String value, BuildContext context) {
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