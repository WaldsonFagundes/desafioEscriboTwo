import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/favorites_providers.dart';
import '../../../models/models.dart';

class HomeScreenTile extends StatefulWidget {
  const HomeScreenTile({
    super.key,
    required this.book,
    required this.index,
  });

  final List<Book> book;
  final int index;

  @override
  State<HomeScreenTile> createState() => _HomeScreenTileState();
}

class _HomeScreenTileState extends State<HomeScreenTile> {
  bool _downloading = false;
  List<Book> favoriteBooks = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    initializeSharedPreferences().then((_) => loadFavoriteBooks());
    super.initState();
  }

  Future<void> _startDownload(int index) async {
    setState(() {
      _downloading = true;
    });

    try {
      final response =
          await http.get(Uri.parse(widget.book[index].downloadUrl));

      if (response.statusCode == 200) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final fileName = widget.book[index].downloadUrl
            .replaceAll(".epub3.images", ".epub")
            .replaceAll(".epub.noimages", ".epub")
            .replaceAll(".epub.images", ".epub")
            .split('/')
            .last;
        final sourceFilePath = '${appDocDir.path}/$fileName';

        final sourceFile = File(sourceFilePath);
        await sourceFile.writeAsBytes(response.bodyBytes);

        final booksDir = Directory('${appDocDir.path}/escribo/books');
        if (!await booksDir.exists()) {
          await booksDir.create(recursive: true);
        }
        if (await booksDir.exists()) {
          final files = await booksDir.list().toList();
          for (var file in files) {
            debugPrint(file.path);
          }
        }
        final destFilePath = '${booksDir.path}/$fileName';

        await sourceFile.copy(destFilePath);

        setState(() {
          _downloading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Livro baixado com sucesso'),
              duration: Duration(seconds: 3),
            ),
          );
        });
      } else {
        throw Exception('Erro ao baixar o livro');
      }
    } catch (error) {
      setState(() {
        _downloading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao baixar o livro'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  void toggleFavorite(int index) {
    setState(() {
      widget.book[index].isFavorite = !widget.book[index].isFavorite;
      if (widget.book[index].isFavorite) {
        favoriteBooks.add(widget.book[index]);
      } else {
        favoriteBooks.remove(widget.book[index]);
      }

      saveFavoriteBooks();

    });
  }

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadFavoriteBooks() async {
    List<int> favoriteIndices = prefs
            .getStringList('favoriteBooks')
            ?.map((index) => int.parse(index))
            .toList() ??
        [];

    setState(() {
      favoriteBooks = favoriteIndices
          .where((index) => index < widget.book.length)
          .map((index) => widget.book[index])
          .toList();

      for (Book book in favoriteBooks) {
        book.isFavorite = true;
      }
    });
  }

  void saveFavoriteBooks() {
    List<String> favoriteIndices = favoriteBooks
        .map((book) => widget.book.indexOf(book).toString())
        .toList();

    prefs.setStringList('favoriteBooks', favoriteIndices);
  }

  @override
  Widget build(BuildContext context) {

    initializeSharedPreferences().then((_) => loadFavoriteBooks());
    Provider.of<FavoritesProvider>(context, listen: false).favoriteBooksProvider = favoriteBooks;

    return Center(
      child: _downloading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text('Downloading'),
              ],
            )
          : GestureDetector(
              onTap: () async {
                _startDownload(widget.index);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.book[widget.index].coverUrl,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        top: 0,
                        right: 8.0,
                        child: InkWell(
                          onTap: () {
                            toggleFavorite(widget.index);
                          },
                          child: Icon(
                            Icons.bookmark,
                            color: widget.book[widget.index].isFavorite
                                ? Colors.red
                                : Colors.white,
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Text(
                                  widget.book[widget.index].title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.fade
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              Text(
                                widget.book[widget.index].author,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
