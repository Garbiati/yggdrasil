import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yggdrasil/services/auth_service.dart';
import 'package:yggdrasil/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_screen.dart';

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
      body: _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _LoginButton(
            text: 'Login com Google',
            assetName: 'assets/images/google_logo.png',
            color: Colors.white,
            textColor: Colors.black,
            onPressed: () async {
              await authService.signInWithGoogle().then((value) => {
                    if (value != null)
                      {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRouter.homeScreen)
                      }
                  });
            },
          ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String text;
  final String assetName;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _LoginButton({
    Key? key,
    required this.text,
    required this.assetName,
    required this.color,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: color,
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              image: AssetImage(assetName),
              height: 35.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
