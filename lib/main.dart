import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/screens.dart';
import '../providers/providers.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => FavoritesProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desafio Escribo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/my_books': (context) => MyBooksScreen(),
      },
    );
  }
}
