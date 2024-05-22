import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:randommovefile/view/help_page.dart';
import 'package:randommovefile/view/home_page.dart';
import 'package:randommovefile/view/settings_page.dart';
import 'package:randommovefile/view/video_selector_page.dart';
import 'package:randommovefile/view/video_split_page.dart';
import 'package:randommovefile/view/censorship_page.dart';
import 'providers/navigation_provider.dart';
import 'view/app_shell.dart';  // 引入违规词消音页面

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<NavigationProvider>(context);
    List<Widget> pages = [
      const HomePage(),
      const AppShell(page: VideoSelectorPage()),
      const AppShell(page: VideoSplitPage()),
      const AppShell(page: CensorshipPage()),
      const AppShell(page: SettingsPage()),
      const AppShell(page: HelpPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('视频处理工具')),
      body: pages.elementAt(provider.selectedIndex),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(title: const Text('主页'), onTap: () => provider.setIndex(0)),
            ListTile(title: const Text('视频移动'), onTap: () => provider.setIndex(1)),
            ListTile(title: const Text('视频分割'), onTap: () => provider.setIndex(2)),
            ListTile(title: const Text('违规词消音'), onTap: () => provider.setIndex(3)),
            ListTile(title: const Text('设置'), onTap: () => provider.setIndex(4)),
            ListTile(title: const Text('帮助'), onTap: () => provider.setIndex(5)),
          ],
        ),
      ),
    );
  }
}
