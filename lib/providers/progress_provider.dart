import 'package:flutter/material.dart';

class ProgressProvider with ChangeNotifier {
  double _progress = 0.0;
  bool _isVisible = false;

  double get progress => _progress;
  bool get isVisible => _isVisible;

  void showProgress(double progress) {
    _progress = progress;
    _isVisible = true;
    notifyListeners();
  }

  void updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void hideProgress() {
    _isVisible = false;
    notifyListeners();
  }
}
