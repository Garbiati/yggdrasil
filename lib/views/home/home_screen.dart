import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yggdrasil/services/auth_service.dart';
import 'package:yggdrasil/config/constants.dart'; // Adicione esta linha
import 'package:yggdrasil/config/app_strings.dart'; // Adicione esta linha

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _authService.getUser(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return const Text(
              kNoUserLoggedInMessage); // Atualizado para usar a string constante
        } else {
          User user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                  kHomePageTitle), // Atualizado para usar a string constante
              actions: [
                IconButton(
                  icon:
                      kAccountIcon, // Atualizado para usar a constante de ícone
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                )
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$kWelcomeMessage${user.displayName ?? user.email}'),
                  Text('$kYourEmailMessage${user.email}'), 
                  // Add more details here
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
