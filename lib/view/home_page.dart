import 'package:flutter/material.dart';
import 'package:randommovefile/view/bililive.dart';
import 'package:randommovefile/view/video_selector_page.dart';
import 'package:randommovefile/view/video_split_page.dart';
import 'package:randommovefile/view/settings_page.dart';
import 'package:randommovefile/view/help_page.dart';
import 'package:randommovefile/view/censorship_page.dart';

import 'app_shell.dart'; // 确保导入了所有页面

enum Status { notRunning, error, running }

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
              }, Status.notRunning),
              _buildFeatureCard(context, '视频分割', Icons.content_cut, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const AppShell(page: VideoSplitPage())));
              }, Status.notRunning),
              _buildFeatureCard(context, '违规词消音', Icons.volume_off, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const AppShell(page: CensorshipPage())));
              }, Status.notRunning),
              _buildFeatureCard(context, '录播姬', Icons.videocam, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const AppShell(page: BililivePage())));
              }, Status.notRunning),
              _buildFeatureCard(context, '设置', Icons.settings, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const AppShell(page: SettingsPage())));
              }, Status.notRunning),
              _buildFeatureCard(context, '帮助', Icons.help_outline, () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AppShell(page: HelpPage())));
              }, Status.notRunning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon,
      Function onTap, Status status) {
    return Card(
      child: InkWell(
        onTap: onTap as void Function()?,
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('$title 控制'),
                content: const Text('你想停止该进程吗？'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle stop action here
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title 停止')),
                      );
                    },
                    child: const Text('停止'),
                  ),
                ],
              );
            },
          );
        },
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 48.0, color: Theme.of(context).primaryColor),
                  Text(title, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: _buildStatusIndicator(status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(Status status) {
    Color color;
    switch (status) {
      case Status.notRunning:
        color = Colors.grey;
        break;
      case Status.error:
        color = Colors.red;
        break;
      case Status.running:
        color = Colors.green;
        break;
    }
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
