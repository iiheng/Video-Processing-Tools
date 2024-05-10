import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MaterialApp(
    home: VideoSelectorPage(),
  ));
}

class VideoSelectorPage extends StatefulWidget {
  const VideoSelectorPage({super.key});

  @override
  _VideoSelectorPageState createState() => _VideoSelectorPageState();
}

class _VideoSelectorPageState extends State<VideoSelectorPage> {
  String? sourceFolder;
  String? destinationFolder;
  int videoCount = 0;
  int repeatCount = 1;

  Future<void> pickSourceFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      setState(() {
        sourceFolder = folderPath;
      });
      Fluttertoast.showToast(
        msg: "源文件夹已选择: $sourceFolder",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> pickDestinationFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      setState(() {
        destinationFolder = folderPath;
      });
      Fluttertoast.showToast(
        msg: "目标文件夹已选择: $destinationFolder",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> copyRandomVideos() async {
    if (sourceFolder == null || destinationFolder == null) {
      Fluttertoast.showToast(
        msg: "请选择源文件夹和目标文件夹",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final List<FileSystemEntity> videos =
        Directory(sourceFolder!).listSync().where((file) {
      return file is File && ['.mp4', '.avi', '.mov', '.mkv', '.flv'].contains(path.extension(file.path).toLowerCase());
    }).toList();

    if (videos.length < videoCount) {
      Fluttertoast.showToast(
        msg: "源文件夹中视频数量不足",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    Random random = Random();

    for (int i = 0; i < repeatCount; i++) {
      final List<File> selectedVideos = List<File>.from(videos)..shuffle(random);
      final String repeatFolder = path.join(destinationFolder!, "Repeat_${i + 1}");
      Directory(repeatFolder).createSync();

      for (int j = 0; j < videoCount; j++) {
        final File video = selectedVideos[j];
        final String destinationPath = path.join(repeatFolder, path.basename(video.path));
        await video.copy(destinationPath);
      }
    }

    Fluttertoast.showToast(
      msg: "视频复制完成",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('随机选择视频'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('源文件夹: ${sourceFolder ?? '未选择'}'),
            ElevatedButton(
              onPressed: pickSourceFolder,
              child: const Text('选择源文件夹'),
            ),
            const SizedBox(height: 16),
            Text('目标文件夹: ${destinationFolder ?? '未选择'}'),
            ElevatedButton(
              onPressed: pickDestinationFolder,
              child: const Text('选择目标文件夹'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '随机选择视频数量',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                videoCount = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '重复次数',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                repeatCount = int.tryParse(value) ?? 1;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: copyRandomVideos,
              child: const Text('开始复制'),
            ),
          ],
        ),
      ),
    );
  }
}
