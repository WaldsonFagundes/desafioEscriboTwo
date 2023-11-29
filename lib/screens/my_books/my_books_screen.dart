import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../../models/book.dart';
import '../../services/services.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});

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
  String filePath = "";

  @override
  void initState() {
    super.initState();

    fetchBookData();
    _loadBookFiles();
  }

  void deleteFile(String path) {
    File file = File(path);

    file.deleteSync();

    setState(() {
      _loadBookFiles();
    });

    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Livro deletado'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao deletar o livro'),
          duration: Duration(seconds: 3),
        ),
      );
    }
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

  Book matchBook(File fileName) {
    for (var book in books) {

      if (fileName.path.split('/').last.contains(book.downloadUrl
          .replaceAll(".epub3.images", ".epub")
          .replaceAll(".epub.noimages", ".epub")
          .replaceAll(".epub.images", ".epub")
          .split('/')
          .last)) {
        return book;
      }
    }
    return Book(id: 0, title: '', author: '', coverUrl: '', downloadUrl: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Livros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: _bookFiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                filePath = _bookFiles[index].path;

                VocsyEpub.setConfig(
                  themeColor: Theme.of(context).primaryColor,
                  identifier: "iosBook",
                  scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                  allowSharing: true,
                  enableTts: true,
                  nightMode: true,
                );

                VocsyEpub.locatorStream.listen((locator) {
                  print('LOCATOR: $locator');
                });

                VocsyEpub.open(
                  filePath,
                  lastLocation: EpubLocator.fromJson({
                    "bookId": "2239",
                    "href": "/OEBPS/ch06.xhtml",
                    "created": 1539934158390,
                    "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
                  }),
                );
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
                        matchBook(_bookFiles[index]).coverUrl,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                          top: 0,
                          left: 8.0,
                          //botao deletar
                          child: IconButton.outlined(
                              onPressed: () {
                                filePath = _bookFiles[index].path;
                                deleteFile(filePath);
                              },
                              icon: Icon(Icons.delete_outline))),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                matchBook(_bookFiles[index]).title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                matchBook(_bookFiles[index]).author,
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
            );
          },
        ),
      ),
    );
  }
}
