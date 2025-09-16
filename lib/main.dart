import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    

    return MaterialApp(
      title: 'Bytelogik App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}