import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/auth_page.dart';
import 'package:modernlogintute/pages/search_loc.dart';
import 'package:firebase_core/firebase_core.dart'; // import firebase core
import 'firebase_options.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized(); // give access
   await Firebase.initializeApp(); // to continuously access from our project to our firebase backend
   runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
