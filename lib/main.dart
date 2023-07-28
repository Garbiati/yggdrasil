import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yggdrasil/router/app_router.dart';
import 'package:yggdrasil/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:yggdrasil/views/login/login_screen.dart';
import 'package:yggdrasil/views/home/home_screen.dart';
import 'config/firebase_options.dart';

Future main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<AppRouter>(create: (_) => AppRouter()),
      ],
      child: const Yggdrasil(),
    ),
  );
}

class Yggdrasil extends StatelessWidget {
  const Yggdrasil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return MaterialApp(
      title: 'Yggdrasil',
      home: ValueListenableBuilder<User?>(
        valueListenable: authService.user,
        builder: (context, user, _) {
          if (user == null) {
            return const LoginScreen(); // A tela de login é mostrada se o usuário não estiver logado
          } else {
            return HomeScreen(); // A tela inicial é mostrada se o usuário estiver logado
          }
        },
      ),
      onGenerateRoute: (settings) {
        if (authService.user.value == null) {
          return MaterialPageRoute(
              builder: (context) =>
                  const LoginScreen()); // Se o usuário não estiver logado, todas as rotas levam à tela de login
        } else {
          return context.read<AppRouter>().onGenerateRoute(
              settings); // Se o usuário estiver logado, as rotas funcionam normalmente
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
