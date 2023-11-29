import 'package:desafio_escribo_two/screens/home/components/components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/favorites_providers.dart';
import '../../services/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> books = [];
  bool showFavorites = false;

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

  void showOnlyFavorites() {
    setState(() {
      showFavorites = !showFavorites;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBookData();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context).favoriteBooksProvider;
    // books = showFavorites ? favoritesProvider.favoriteBooksProvider : books;

    debugPrint(
        'booooooks ' + books.map((e) => e.author).toString() + 'xxxxxxxxxxx');

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
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/my_books');
                    },
                    child: const Text('Meus livros')),
                const SizedBox(
                  width: 6,
                ),
                //Botão favorito
                ElevatedButton(
                  onPressed: () {
                    showOnlyFavorites();
                    debugPrint('xxxx bool' + showFavorites.toString());
                  },
                  child: const Text('Favoritos'),
                  style: ButtonStyle(
                    backgroundColor: showFavorites ? MaterialStateProperty.all<Color>(Colors.red.withOpacity(0.5)) : null
                  ),
                ),
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
                itemCount:
                    showFavorites ? favoritesProvider.length : books.length,
                itemBuilder: (BuildContext context, int index) {
                  return showFavorites
                      ? HomeScreenTile(book: favoritesProvider, index: index)
                      : HomeScreenTile(book: books, index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
