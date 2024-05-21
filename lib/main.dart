import 'package:flutter/material.dart';
import 'main_drawer.dart'; // 确保导入MainDrawer文件
import 'package:window_manager/window_manager.dart';
Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    minimumSize: Size(400, 300)
  );
  windowManager.setTitle("视频处理软件");
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
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
