import 'package:flutter/foundation.dart';

import '../models/models.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Book> favoriteBooksProvider = [];

  void updateFavorites(List<Book> updatedFavorites) {
    favoriteBooksProvider = updatedFavorites;
    notifyListeners();
  }
}