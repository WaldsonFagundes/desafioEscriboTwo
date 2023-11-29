import 'package:flutter/foundation.dart';

import '../models/book.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Book> favoriteBooksProvider = [];

  void updateFavorites(List<Book> updatedFavorites) {
    favoriteBooksProvider = updatedFavorites;
    notifyListeners();
  }
}