import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/book.dart';
import '../../services/api_escribo.dart';

class MyBooksScreen extends StatefulWidget {
  @override
  _MyBooksScreenState createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
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

  late Directory _booksDir;
  late List<File> _bookFiles = [];

  @override
  void initState() {
    super.initState();

    fetchBookData();
    _loadBookFiles();
  }

  Future<void> _loadBookFiles() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _booksDir = Directory('${appDocDir.path}/escribo/books');
    if (await _booksDir.exists()) {
      final files = _booksDir.listSync();

      _bookFiles = files.whereType<File>().toList();

      setState(() {});
    }
  }

  Book findBook(File fileName) {
    for (var book in books) {
      if (fileName.path
          .split('/')
          .last
          .contains(book.downloadUrl.split('/').last)) {
        return book;
      }
    }
    return Book (id: 0, title: '', author: '', coverUrl: '', downloadUrl: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Livros'),
      ),
      body: GridView.builder(
        itemCount: _bookFiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Implemente o que deseja fazer ao clicar em um livro
            },
            child: GridTile(
              footer: GridTileBar(
                backgroundColor: Colors.black45,
                title: Text(
                  findBook(_bookFiles[index]).title, // Nome do arquivo
                  textAlign: TextAlign.center,
                ),
              ),
              child: Image.network(findBook(_bookFiles[index]).coverUrl),
            ),
          );
        },
      ),
    );
  }
}
