import 'dart:ui';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<String> covers = [
    'https://www.gutenberg.org/cache/epub/72134/pg72134.cover.medium.jpg',
    'https://www.gutenberg.org/cache/epub/72127/pg72127.cover.medium.jpg',
    "https://www.gutenberg.org/cache/epub/72126/pg72126.cover.medium.jpg",
    "https://www.gutenberg.org/cache/epub/63606/pg63606.cover.medium.jpg",
    "https://www.gutenberg.org/cache/epub/72135/pg72135.cover.medium.jpg",
    "https://www.gutenberg.org/cache/epub/18452/pg18452.cover.medium.jpg",
  ];


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(onPressed: (){}, child: Text('Livros')),
                 const SizedBox(width: 6,),
                ElevatedButton(onPressed: (){}, child: Text('Favoritos')),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: covers.length,
                itemBuilder: (BuildContext context, int index) {
                  return HomeScreenTile(covers: covers, index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreenTile extends StatelessWidget {
  const HomeScreenTile({
    super.key,
    required this.covers,
    required this.index,
  });

  final List<String> covers;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //TODO: implementar acesso ao conteudo do livro
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey
          ),
          child: Stack (
            fit: StackFit.expand,
            children: [


              Image.network(
                covers[index],
                fit: BoxFit.contain,
              ),
              const Positioned(
                top: 0,
                right: 8.0,
                child: InkWell(
                 //TODO: Implementar
                  child: Icon(
                    Icons.bookmark,
                    color: Colors.amber,
                    size: 32.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child:  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children:  [
                      Text(
                        'Title',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Author',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

