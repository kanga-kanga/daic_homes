import 'package:daic_home/main.dart';
import 'package:daic_home/pages/on_boarding_page.dart';
// import 'package:daic_home/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck extends StatelessWidget {
  // obtenir l'instance de SharedPreferences
  Future<bool> _getAuthenticationStatus() async {
    final _prefs = await SharedPreferences.getInstance();
    // lire la valeur de isAuthenticated
    // _prefs.remove('isAuthenticated');
    // _prefs.remove('userId');
    // _prefs.remove('userEmail');
    return _prefs.getBool('isAuthenticated') ?? false;
  }

  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _getAuthenticationStatus(),
      // future: AuthService().isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Affichez un écran de chargement pendant la vérification
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          // Si l'utilisateur est connecté, redirigez vers HomePage
          return const MainPage();
        } else {
          // Sinon, redirigez vers la page de connexion
          return const OnboardingPage();
        }
      },
    );
  }
}
