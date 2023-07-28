import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yggdrasil/services/auth_service.dart';
import 'package:yggdrasil/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yggdrasil/widgets/login_button.dart';
import 'package:yggdrasil/config/constants.dart'; // Adicione esta linha
import 'package:yggdrasil/config/app_strings.dart'; // Adicione esta linha
import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user != null) {
      // Se o usuário estiver logado, redireciona para a tela inicial.
      return HomeScreen();
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
          LoginButton(
            text: kGoogleLoginButtonText,
            assetName: kGoogleLogoAssetName,
            color: kGoogleButtonColor,
            textColor: kGoogleButtonTextColor,
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
