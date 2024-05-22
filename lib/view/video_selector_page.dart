import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../providers/progress_provider.dart';

class VideoSelectorPage extends StatefulWidget {
  const VideoSelectorPage({super.key});

  @override
  _VideoSelectorPageState createState() => _VideoSelectorPageState();
}

class _VideoSelectorPageState extends State<VideoSelectorPage> {
  String? sourceFolder;
  String? destinationFolder;
  List<FileSystemEntity> sourceFiles = [];
  List<FileSystemEntity> destinationFiles = [];
  int videoCount = 0;
  int repeatCount = 1;
  bool clearDestination = false;
  Map<String, bool> selecteddestinationFiles = {}; // 追踪选中的文件

  Future<void> pickSourceFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      final List<FileSystemEntity> files = Directory(folderPath).listSync();
      setState(() {
        sourceFolder = folderPath;
        sourceFiles = files;
      });
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title: const Text('选择文件成功'),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> pickDestinationFolder() async {
  String? folderPath = await FilePicker.platform.getDirectoryPath();
  if (folderPath != null) {
    // 使用listSync()获取所有项，然后使用where()筛选出目录
    final List<FileSystemEntity> directories = Directory(folderPath)
      .listSync()
      .whereType<Directory>()
      .toList();

    setState(() {
      destinationFolder = folderPath;
      destinationFiles = directories;  // 更新destinationFiles，现在它只包含目录
    });

    toastification.show(
      context: context, // optional if you use ToastificationWrapper
      title: const Text('选择文件成功'),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }
}


  Future<void> clearVideosInFolder(String folderPath) async {
    final directory = Directory(folderPath);
    if (await directory.exists()) {
      final List<FileSystemEntity> files = directory.listSync();
      for (var file in files) {
        try {
          if (file is File && ['.mp4', '.avi', '.mov', '.mkv', '.flv'].contains(path.extension(file.path).toLowerCase())) {
            await file.delete();
          }
        } catch (e) {
          toastification.show(
            context: context, // optional if you use ToastificationWrapper
            title:  Text("无法删除文件: ${file.path}, 可能文件正在使用中"),
            autoCloseDuration: const Duration(seconds: 2),
          );
        }
      }
    }
  }

  Future<void> copyRandomVideos(ProgressProvider progressProvider) async {
    print("Selected Files: $selecteddestinationFiles");
    progressProvider.showProgress(0.0);
    if (sourceFolder == null || destinationFolder == null) {
      _showToast("请选择源文件夹和目标文件夹");
      return;
    }

    final List<FileSystemEntity> videos = _getVideosFromSourceFolder();
    if (videos.length < videoCount) {
      _showToast("源文件夹中视频数量不足");
      return;
    }

    List<String> selectedFolders = selecteddestinationFiles.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (selectedFolders.isNotEmpty) {
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title: const Text("修改选中的文件夹"),
        autoCloseDuration: const Duration(seconds: 2),
      );
      await _copyVideosToSelectedFolders(selectedFolders, videos,progressProvider);
    } else {
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        title: const Text("未选择任何文件夹，直接复制"),
        autoCloseDuration: const Duration(seconds: 2),
      );
      await _copyVideosToRepeatedFolders(videos, progressProvider);
    }
    progressProvider.hideProgress();
    _showToast("视频复制完成");
  }

  void _showToast(String message) {
    toastification.show(
      context: context, // optional if you use ToastificationWrapper
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  List<FileSystemEntity> _getVideosFromSourceFolder() {
    return Directory(sourceFolder!).listSync().where((file) {
      return file is File &&
          ['.mp4', '.avi', '.mov', '.mkv', '.flv'].contains(path.extension(file.path).toLowerCase());
    }).toList();
  }

  Future<void> _copyVideosToSelectedFolders(List<String> selectedFolders, List<FileSystemEntity> videos, ProgressProvider progressProvider) async {
    Random random = Random();
    double currentProgress = 0.0;

    for (int i = 0; i < selectedFolders.length; i++) {
      String folder = selectedFolders[i];
      if (clearDestination) {
        await clearVideosInFolder(folder);
      }

      final List<File> selectedVideos = List<File>.from(videos)..shuffle(random);
      await _copyVideos(selectedVideos, folder);

      // 更新进度条
      currentProgress = (i + 1) / selectedFolders.length;
      progressProvider.updateProgress(currentProgress);
    }
  }


  Future<void> _copyVideosToRepeatedFolders(List<FileSystemEntity> videos, ProgressProvider progressProvider) async {
    Random random = Random();
    double currentProgress = 0.0;

    for (int i = 0; i < repeatCount; i++) {
      final String repeatFolder = path.join(destinationFolder!, "Repeat_${i + 1}");
      await Directory(repeatFolder).create(recursive: true);

      if (clearDestination) {
        await clearVideosInFolder(repeatFolder);
      }

      final List<File> selectedVideos = List<File>.from(videos)..shuffle(random);
      await _copyVideos(selectedVideos, repeatFolder);

      // 更新进度条
      currentProgress = (i + 1) / repeatCount;
      progressProvider.updateProgress(currentProgress);
    }
  }


  Future<void> _copyVideos(List<File> selectedVideos, String destinationFolder) async {
    for (int j = 0; j < videoCount; j++) {
      final File video = selectedVideos[j];
      final String destinationPath = path.join(destinationFolder, path.basename(video.path));
      try {
        await video.copy(destinationPath);
      } catch (e) {
        _showToast("无法复制文件: ${video.path}, 目标路径: $destinationPath");
      }
    }
  }
  void selectAll() {
    setState(() {
      for (var file in destinationFiles) {
        selecteddestinationFiles[file.path] = true;
      }
    });
  }
  void deselectAll() {
    setState(() {
      for (var file in destinationFiles) {
        selecteddestinationFiles[file.path] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ProgressProvider progressProvider = Provider.of<ProgressProvider>(context, listen: false);
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
if (destinationFiles.isNotEmpty) SizedBox(
  height: 150,
  child: ListView.builder(
    itemCount: destinationFiles.length,
    itemExtent: 20, // 设置每个列表项的固定高度
    itemBuilder: (BuildContext context, int index) {
      FileSystemEntity file = destinationFiles[index];
      String filePath = file.path;
      bool isSelected = selecteddestinationFiles[filePath] ?? false; // 获取当前文件的选中状态

      return GestureDetector(
        onTap: () {
          setState(() {
            selecteddestinationFiles[filePath] = !isSelected; // 更新选中状态
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0), // 水平内边距
          child: Row(
            children: [
              Icon(Icons.folder, color: Colors.yellow[600], size: 20), // 文件夹图标
              const SizedBox(width: 10), // 图标和文本之间的间距
              Expanded(
                child: Text(
                  path.basename(filePath),
                  style: const TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Transform.scale(
                scale: 0.8, // 缩小复选框
                child: Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      selecteddestinationFiles[filePath] = value ?? false; // 更新选中状态
                    });
                  },
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
),
 const SizedBox(height: 16),
 if (destinationFiles.isNotEmpty) Row(
              children: [
                ElevatedButton(
                  onPressed: selectAll,
                  child: const Text('全选'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: deselectAll,
                  child: const Text('全部取消'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('在复制前清空目标文件夹视频:'),
                Checkbox(
                  value: clearDestination,
                  onChanged: (bool? value) {
                    setState(() {
                      clearDestination = value ?? false;
                    });
                  },
                ),
              ],
            ),
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
              onPressed: ()=> copyRandomVideos(progressProvider),
              child: const Text('开始复制'),
            ),
          ],
        ),
      ),
    );
  }
}
