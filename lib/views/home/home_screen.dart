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
          return const Text(kNoUserLoggedInMessage);
        } else {
          User user = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text(kHomePageTitle),
              actions: [
                IconButton(
                  icon: kAccountIcon,
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/health_insurance_reimbursement');
                    },
                    child: const Text('Solicitar Reembolso Plano de Saúde'),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
