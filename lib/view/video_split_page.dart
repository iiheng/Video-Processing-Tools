// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:randommovefile/utils/FFmpegHandler.dart';
import 'package:toastification/toastification.dart';

class VideoSplitPage extends StatefulWidget {
  const VideoSplitPage({super.key});

  @override
  _VideoSplitPageState createState() => _VideoSplitPageState();
}

class _VideoSplitPageState extends State<VideoSplitPage> {
  TextEditingController videoPathController = TextEditingController();
  TextEditingController saveFolderPathController = TextEditingController();
  TextEditingController splitDurationController = TextEditingController();
  TextEditingController splitCountController = TextEditingController();
  bool shouldSplitContinuously = false;  // 新增勾选框的状态
  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      setState(() {
        videoPathController.text = filePath ?? '';
      });
    }
  }

  Future<void> selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        saveFolderPathController.text = selectedDirectory;
      });
    }
  }

  Future<void> splitVideo() async {
    if (videoPathController.text.isEmpty || saveFolderPathController.text.isEmpty || splitDurationController.text.isEmpty) {
      toastification.show(
        context: context,
        title: const Text('请确保所有字段都已填写并且是有效的。'),
        autoCloseDuration: const Duration(seconds: 2),
      );
      return;
    }

    int duration = int.parse(splitDurationController.text);
    int videoLength = await FFmpegHandler.getVideoDuration(videoPathController.text);
    print("视频时长：$videoLength秒");
    if (videoLength <= duration) {
      toastification.show(
        context: context,
        title: const Text('截取时长不能大于或等于视频总时长'),
        autoCloseDuration: const Duration(seconds: 2),
      );
      return;
    }

    Random random = Random();
    List<String> results = [];
    int count = shouldSplitContinuously ? (videoLength / duration).floor() : int.parse(splitCountController.text);

    for (int i = 0; i < count; i++) {
      int start = shouldSplitContinuously ? i * duration : random.nextInt(videoLength - duration);
      String outputPath = "${saveFolderPathController.text}/output_${i.toString().padLeft(3, '0')}.mp4";
      
      List<String> arguments = [
        "-ss",
        start.toString(),
        "-i",
        videoPathController.text,
        "-t",
        duration.toString(),
        "-c",
        "copy",
        outputPath
      ];

      String result = await FFmpegHandler.executeFFmpeg(arguments);
      results.add(result);
    }

    // 显示操作结果
    toastification.show(
      context: context,
      title: Text(results.every((result) => result.contains("运行结束")) ? '视频分割成功' : '视频分割失败'),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频分割'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextFormField(
              controller: videoPathController,
              decoration: InputDecoration(
                labelText: '视频文件地址',
                hintText: '输入或选择视频文件路径',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: selectFile,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: saveFolderPathController,
              decoration: InputDecoration(
                labelText: '保存文件夹地址',
                hintText: '输入或选择保存文件夹路径',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: selectFolder,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: splitDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '分割后的视频时长（秒）',
                hintText: '输入每段视频的时长',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: splitCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '分割的视频数量',
                      hintText: '输入要分割出的视频数量',
                    ),
                    enabled: !shouldSplitContinuously, // 根据勾选框状态启用或禁用
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: CheckboxListTile(
                    title: const Text('根据时长连续分割视频'),
                    value: shouldSplitContinuously,
                    onChanged: (bool? value) {
                      setState(() {
                        shouldSplitContinuously = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: splitVideo,
              child: const Text('开始分割'),
            ),
          ],
        ),
      ),
    );
  }
}
