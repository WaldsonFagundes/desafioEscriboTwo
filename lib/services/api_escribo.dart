import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

Future<List<Book>> fetchBooks() async {
  final response = await http.get(Uri.parse('https://escribo.com/books.json'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    List<Book> books = jsonData.map((data) => Book.fromJson(data)).toList();
    return books;
  } else {
    throw Exception('Failed to load books');
  }
}
