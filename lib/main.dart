import 'package:flutter/material.dart';
import 'main_drawer.dart'; // 确保导入MainDrawer文件

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '视频处理工具',  // 应用的标题
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainDrawer(),  // 使用MainDrawer作为主页面
    );
  }
}
