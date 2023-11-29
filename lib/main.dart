
import 'package:desafio_escribo_two/providers/favorites_providers.dart';
import 'package:desafio_escribo_two/screens/my_books/my_books_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/screens.dart';

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
        '/': (context) => HomeScreen(),
        '/my_books': (context) => MyBooksScreen(),
      },
    );
  }
}
