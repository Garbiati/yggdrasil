import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yggdrasil/widgets/login_body.dart';

import '../home/home_screen.dart'; // adicione esta linha para importar o LoginBody

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user != null) {
      // Se o usuário estiver logado, redireciona para a tela inicial.
      return HomeScreen(); // Substitua por sua tela inicial.
    }

    // Se o usuário não estiver logado, mostra a tela de login.
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const LoginBody(), // substitua _LoginBody por LoginBody
        ],
      ),
    );
  }
}
