import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment/Authentication/login_screen.dart';
import 'package:payment/homepage.dart';

class Authenticate extends StatelessWidget {
  final auth = FirebaseAuth.instance;

  Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    if (auth.currentUser != null) {
      return const HomePage();
    } else {
      return const LoginScreen();
    }
  }
}
