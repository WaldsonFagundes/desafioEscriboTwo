import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
     HomeScreen({super.key});

    final List<String> coversTest = [
      'https://www.gutenberg.org/cache/epub/72134/pg72134.cover.medium.jpg',
      'https://www.gutenberg.org/cache/epub/72127/pg72127.cover.medium.jpg',


    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title:  const Text('Minha Biblioteca'),
        ),
        body: Padding(
          padding:const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: coversTest.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                 //TODO: implementar acesso ao conteudo do livro
                },
                child: Image.network(
                  coversTest[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      );
    }
}
