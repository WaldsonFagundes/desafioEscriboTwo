import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../models/models.dart';
import '../services/services.dart';

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
                  crossAxisCount: 2,
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
//------------------------

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
  Dio dio = Dio();
  String filePath = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    startDownload(String urlDownload) async {
      setState(() {});
      Directory? appDocDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      String path = appDocDir!.path + '/sample.epub';
      File file = File(path);

      if (!File(path).existsSync()) {
        await file.create();
        await dio.download(
          urlDownload,
          path,
          deleteOnError: true,
          onReceiveProgress: (receivedBytes, totalBytes) {
            print('Download --- ${(receivedBytes / totalBytes) * 100}');
            setState(() {});
          },
        ).whenComplete(() {
          setState(() {
            filePath = path;
          });
        });
      } else {
        setState(() {
          filePath = path;
        });
      }
    }

    return GestureDetector(
      onTap: () async {
        startDownload(widget.book[widget.index].downloadUrl).whenComplete(() {
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
        });

      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: Colors.grey),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.book[widget.index].coverUrl,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.book[widget.index].title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
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
    );
  }
}
