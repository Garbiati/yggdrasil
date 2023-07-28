import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yggdrasil/services/auth_service.dart';
import 'package:yggdrasil/widgets/login_button.dart';
import '../views/home/home_screen.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            Positioned(
              top: constraints.maxHeight * 0.4, // 40% da altura total da tela
              left: 0,
              right: 0,
              child: const Text(
                'Yggdrasil',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: constraints.maxHeight * 0.2, // 20% da altura total da tela
              left: 0,
              right: 0,
              child: SizedBox(
                height:
                    constraints.maxHeight * 0.2, // 20% da altura total da tela
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset('assets/icons/YggdrasilBerry.png'),
                ),
              ),
            ),
            Positioned(
              bottom:
                  constraints.maxHeight * 0.2, // 20% da altura total da tela
              left: 0,
              right: 0,
              child: LoginButton(
                text: 'Login com Google',
                assetName: 'assets/images/google_logo.png',
                color: Colors.white,
                textColor: Colors.black,
                onPressed: () async {
                  await authService.signInWithGoogle().then((value) => {
                        if (value != null)
                          {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                              (route) => false,
                            )
                          }
                      });
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
