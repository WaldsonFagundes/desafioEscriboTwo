import 'dart:io';

import 'package:desafio_escribo_two/models/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
      //TODO: delete
      debugPrint('xxxxxxxxxx' + path);

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
        await startDownload(widget.book[widget.index].downloadUrl);

        if(filePath.isNotEmpty){
          VocsyEpub.setConfig(
            themeColor: Theme.of(context).primaryColor,
            identifier: "iosBook",
            scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
            allowSharing: true,
            enableTts: true,
            nightMode: true,
          );


          VocsyEpub.open(
            filePath,
            lastLocation: EpubLocator.fromJson({
              "bookId": "2239",
              "href": "/OEBPS/ch06.xhtml",
              "created": 1539934158390,
              "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
            }),
          );
        } else {
          debugPrint('Download fail');
        }
        VocsyEpub.locatorStream.listen((locator) {
          print('LOCATOR: $locator');
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
