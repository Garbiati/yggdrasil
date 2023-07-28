import 'package:flutter/material.dart';
import 'package:yggdrasil/views/login/login_screen.dart';
import 'package:yggdrasil/views/home/home_screen.dart';
import 'package:yggdrasil/views/profile/profile_screen.dart';
import 'package:yggdrasil/views/reimbursement/health_insurance_reimbursement_screen.dart';

class AppRouter {
  static const String homeScreen = '/home';
  static const String profileScreen = '/profile';
  static const String healthInsuranceReimbursementScreen =
      '/health_insurance_reimbursement';

  static const String loginScreen = '/';

  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case profileScreen:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case healthInsuranceReimbursementScreen:
        return MaterialPageRoute(
            builder: (_) => const HealthInsuranceReimbursementScreen());
      default:
        return null;
    }
  }
}
