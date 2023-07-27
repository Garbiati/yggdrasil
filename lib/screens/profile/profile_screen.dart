import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yggdrasil/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService =
        Provider.of<AuthService>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<User?>(
              valueListenable: authService.user,
              builder: (context, user, child) {
                if (user != null) {
                  return Column(
                    children: [
                      Text('Your UID: ${user.uid}'),
                      Text('Your name: ${user.displayName ?? user.email}'),
                      Text('Your email: ${user.email}'),
                    ],
                  );
                } else {
                  return const Text('No user logged in.');
                }
              },
            ),
            ElevatedButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                await authService.signOut().then(
                    (value) => {Navigator.pushReplacementNamed(context, '/')});
              },
            ),
          ],
        ),
      ),
    );
  }
}
