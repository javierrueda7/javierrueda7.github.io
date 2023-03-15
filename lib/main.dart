import 'package:albaterrapp/pages/edit_quote.dart';
import 'package:albaterrapp/pages/edit_user_page.dart';
import 'package:albaterrapp/pages/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:albaterrapp/firebase_options.dart';

// Pages
import 'package:albaterrapp/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albaterrapp',
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInPage(),
        '/user': (context) => const Home(),
        '/edit': (context) => const EditUserPage(),
      },
    );
  }
}

