import 'package:flutter/material.dart';
import 'package:randommovefile/view/video_selector_page.dart';
import 'package:randommovefile/view/video_split_page.dart';
import 'package:randommovefile/view/settings_page.dart';
import 'package:randommovefile/view/help_page.dart';
import 'package:randommovefile/view/censorship_page.dart';

import 'app_shell.dart'; // 确保导入了所有页面

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            padding: const EdgeInsets.all(4.0),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            children: <Widget>[
              _buildFeatureCard(context, '视频移动', Icons.move_to_inbox, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const AppShell(page: VideoSelectorPage())));
              }),
              _buildFeatureCard(context, '视频分割', Icons.content_cut, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const AppShell(page: VideoSplitPage())));
              }),
              _buildFeatureCard(context, '违规词消音', Icons.volume_off, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const AppShell(page: CensorshipPage())));
              }),
              _buildFeatureCard(context, '设置', Icons.settings, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const AppShell(page: SettingsPage())));
              }),
              _buildFeatureCard(context, '帮助', Icons.help_outline, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AppShell(page: HelpPage())));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, String title, IconData icon, Function onTap) {
    return Card(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
