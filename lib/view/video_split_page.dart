import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
            TextFormField(
              controller: splitCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '分割的视频数量',
                hintText: '输入要分割出的视频数量',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 这里添加视频分割逻辑
                print('开始分割视频');
              },
              child: const Text('开始分割'),
            ),
          ],
        ),
      ),
    );
  }
}
