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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LoginButton(
            text: 'Login com Google',
            assetName: 'assets/images/google_logo.png',
            color: Colors.white,
            textColor: Colors.black,
            onPressed: () async {
              await authService.signInWithGoogle().then((value) => {
                    if (value != null)
                      {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                          (route) => false,
                        )
                      }
                  });
            },
          ),
        ],
      ),
    );
  }
}
