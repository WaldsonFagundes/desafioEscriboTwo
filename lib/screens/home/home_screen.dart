
import 'package:desafio_escribo_two/screens/home/components/components.dart';
import 'package:flutter/material.dart';


import '../../models/models.dart';
import '../../services/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> books = [];

  Future<void> fetchBookData() async {
    try {
      List<Book> fetchedBooks = await fetchBooks();
      setState(() {
        books = fetchedBooks;
      });
    } catch (e) {
      print('Erro ao carregar livros: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookData();
  }

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
                ElevatedButton(onPressed: () {}, child: Text('Livros')),
                const SizedBox(
                  width: 6,
                ),
                ElevatedButton(onPressed: () {}, child: Text('Favoritos')),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: books.length,
                itemBuilder: (BuildContext context, int index) {
                  return HomeScreenTile(book: books, index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}






