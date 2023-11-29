import 'dart:io';

import 'package:desafio_escribo_two/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  Future<void> _startDownload(int index) async {
    setState(() {
      _downloading = true;
    });

    try {
      final response = await http.get(Uri.parse(widget.book[index].downloadUrl));

      if (response.statusCode == 200) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final fileName = widget.book[index].downloadUrl.replaceAll(".epub3.images", ".epub").replaceAll(".epub.noimages", ".epub").replaceAll(".epub.images", ".epub").split('/').last;
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
              duration: Duration(seconds: 3), // Duração da SnackBar
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _downloading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text('Downloading.... E-pub'),
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
            ),
    );
  }
}

/*


import 'dart:io';

import 'package:desafio_escribo_two/models/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

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
  final platform = const MethodChannel('my_channel');
  bool loading = false;
  Dio dio = Dio();
  String filePath = "";

  @override
  void initState() {
    download("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: loading ?
      const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text('Downloading.... E-pub'),
        ],
      )
          : GestureDetector(
        onTap: () async {
          if (filePath == "") {
            download(widget.book[widget.index].downloadUrl);
          } else {
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
          }
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
      ),
    );
  }

  Future<void> fetchAndroidVersion(String url) async {
    final String? version = await getAndroidVersion();
    if (version != null) {
      String? firstPart;
      if (version.toString().contains(".")) {
        int indexOfFirstDot = version.indexOf(".");
        firstPart = version.substring(0, indexOfFirstDot);
      } else {
        firstPart = version;
      }
      int intValue = int.parse(firstPart);
      if (intValue >= 13) {
        await startDownload(url);
      } else {
        final PermissionStatus status = await Permission.storage.request();
        if (status == PermissionStatus.granted) {
          await startDownload(url);
        } else {
          await Permission.storage.request();
        }
      }
      print("ANDROID VERSION: $intValue");
    }
  }

  Future<String?> getAndroidVersion() async {
    try {
      final String version = await platform.invokeMethod('getAndroidVersion');
      return version;
    } on PlatformException catch (e) {
      print("FAILED TO GET ANDROID VERSION: ${e.message}");
      return null;
    }
  }

  startDownload(String url) async {
    setState(() {
      loading = true;
    });
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = '${appDocDir!.path}/sample.epub';
    File file = File(path);

    if (!File(path).existsSync()) {
      await file.create();
      await dio.download(
        url,
        path,
        deleteOnError: true,
        onReceiveProgress: (receivedBytes, totalBytes) {
          print('Download --- ${(receivedBytes / totalBytes) * 100}');
          setState(() {
            loading = true;
          });
        },
      ).whenComplete(() {
        setState(() {
          loading = false;
          filePath = path;
        });
      });
    } else {
      setState(() {
        loading = false;
        filePath = path;
      });
    }
  }

  download(String url) async {
    if (Platform.isIOS) {
      final PermissionStatus status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
        await startDownload(url);
      } else {
        await Permission.storage.request();
      }
    } else if (Platform.isAndroid) {
      await fetchAndroidVersion(url);
    } else {
      PlatformException(code: '500');
    }
  }
}
*/
