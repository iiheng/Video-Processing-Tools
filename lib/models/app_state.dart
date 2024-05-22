import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  String? sourceFolder;
  String? destinationFolder;
  // 其他状态变量

  AppState() {
    loadPreferences();
  }

  void setSourceFolder(String? path) {
    sourceFolder = path;
    savePreferences();
    notifyListeners();
  }

  void setDestinationFolder(String? path) {
    destinationFolder = path;
    savePreferences();
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    sourceFolder = prefs.getString('sourceFolder');
    destinationFolder = prefs.getString('destinationFolder');
    // 加载其他状态变量
    notifyListeners();
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sourceFolder', sourceFolder ?? "");
    await prefs.setString('destinationFolder', destinationFolder ?? "");
    // 保存其他状态变量
  }
}
