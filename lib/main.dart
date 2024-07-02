import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:payment/Authentication/authenticate.dart';
import 'package:payment/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Authenticate()));
}
