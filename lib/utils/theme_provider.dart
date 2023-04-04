import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _theme = ThemeData(primarySwatch: Colors.purple);

  ThemeData get theme => _theme;

  void setTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }
}
