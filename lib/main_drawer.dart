import 'package:flutter/material.dart';
import 'package:randommovefile/view/help_page.dart';
import 'package:randommovefile/view/home_page.dart';
import 'package:randommovefile/view/settings_page.dart';
import 'package:randommovefile/view/video_selector_page.dart';
import 'package:randommovefile/view/video_split_page.dart';
import 'package:randommovefile/view/censorship_page.dart';  // 引入违规词消音页面

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const VideoSelectorPage(),
    const VideoSplitPage(),
    const SettingsPage(),
    const HelpPage(),
    const CensorshipPage(),  // 添加违规词消音页面
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);  // 关闭抽屉
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('视频处理工具')),
      body: _pages.elementAt(_selectedIndex),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: const Text('主页'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              title: const Text('视频移动'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              title: const Text('视频分割'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              title: const Text('违规词消音'),  // 新增导航项
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              title: const Text('设置'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              title: const Text('帮助'),
              onTap: () => _onItemTapped(4),
            ),
            
          ],
        ),
      ),
    );
  }
}
