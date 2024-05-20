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
      final List<FileSystemEntity> files = Directory(folderPath).listSync();
      setState(() {
        destinationFolder = folderPath;
        destinationFiles = files;
      });
      Fluttertoast.showToast(
        msg: "目标文件夹已选择: $destinationFolder",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
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
          Fluttertoast.showToast(
            msg: "无法删除文件: ${file.path}, 可能文件正在使用中",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
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
      final String repeatFolder = path.join(destinationFolder!, "Repeat_${i + 1}");
      await Directory(repeatFolder).create(recursive: true);

      if (clearDestination) {
        await clearVideosInFolder(repeatFolder);
      }

      final List<File> selectedVideos = List<File>.from(videos)..shuffle(random);
      for (int j = 0; j < videoCount; j++) {
        final File video = selectedVideos[j];
        final String destinationPath = path.join(repeatFolder, path.basename(video.path));
        try {
          await video.copy(destinationPath);
        } catch (e) {
          Fluttertoast.showToast(
            msg: "无法复制文件: ${video.path}, 目标路径: $destinationPath",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }
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
            // if (sourceFiles.isNotEmpty) Expanded(
            //   child: GridView.builder(
            //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 8,
            //       crossAxisSpacing: 2,
            //       mainAxisSpacing: 1,
            //     ),
            //     itemCount: sourceFiles.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       return GridTile(
            //         footer: GridTileBar(
            //           backgroundColor: Colors.black45,
            //           title: Text(
            //             path.basename(sourceFiles[index].path),
            //             textAlign: TextAlign.center,
            //             style: const TextStyle(fontSize: 15),
            //           ),
            //         ),
            //         child: Center(
            //           child: Icon(Icons.folder, color: Colors.yellow[600]),  // 根据文件类型显示图标
            //         ),
            //       );
            //     },
            //   ),
            // ),
            const SizedBox(height: 16),
            Text('目标文件夹: ${destinationFolder ?? '未选择'}'),
            ElevatedButton(
              onPressed: pickDestinationFolder,
              child: const Text('选择目标文件夹'),
            ),

            if (destinationFiles.isNotEmpty) Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 1,
                ),
                itemCount: destinationFiles.length,
                itemBuilder: (BuildContext context, int index) {
                  FileSystemEntity file = destinationFiles[index];
                  String filePath = file.path;
                  bool isSelected = selecteddestinationFiles[filePath] ?? false; // 获取当前文件的选中状态

                  return GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black45,
                      title: Text(
                        path.basename(filePath),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Center(
                          child: Icon(file is Directory ? Icons.folder : Icons.insert_drive_file, color: Colors.yellow[600]),  // 根据文件类型显示图标
                        ),
                        Positioned(
                          right: 0,
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
                  );
                },
              ),
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
              onPressed: copyRandomVideos,
              child: const Text('开始复制'),
            ),
          ],
        ),
      ),
    );
  }
}
