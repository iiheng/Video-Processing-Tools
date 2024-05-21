import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'dart:io';

import 'package:randommovefile/utils/FFmpegHandler.dart';

class CensorshipPage extends StatefulWidget {
  const CensorshipPage({Key? key}) : super(key: key);

  @override
  _CensorshipPageState createState() => _CensorshipPageState();
}

class _CensorshipPageState extends State<CensorshipPage> {
  String _videoPath = '';
  String _subtitlePath = '';
  String _bannedWords = '';
  final List<String> _timeStamps = [];
  List<Map<String, String>> _matches = [];  // 存储完整的匹配信息
   Future<void> pickVideoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _videoPath = result.files.single.path!;
      });
    }
  }

  Future<void> pickSubtitleFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['srt'],
        type: FileType.custom,
      );
      if (result != null) {
        setState(() {
          _subtitlePath = result.files.single.path!;
        });
      }
    }

Future<List<Map<String, String>>> matchBannedWords() async {
    File subtitleFile = File(_subtitlePath);
    List<String> bannedWordsList = _bannedWords.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    List<Map<String, String>> matches = [];

    String content = await subtitleFile.readAsString();
    RegExp exp = RegExp(r'^(\d+)\s*\r?\n([0-9,:-]+ --> [0-9,:-]+)\r?\n(.*(?:\r?\n(?!\r?\n).*)*)', multiLine: true);
    Iterable<RegExpMatch> entries = exp.allMatches(content);

    for (var entry in entries) {
      String index = entry.group(1)!.trim();
      String timeLine = entry.group(2)!.trim();
      String text = entry.group(3)!.replaceAll('\r\n', '\n').trim();

      for (var word in bannedWordsList) {
        if (text.contains(word)) {
          matches.add({'index': index, 'time': timeLine, 'text': text});
          break;
        }
      }
    }

    return matches;
  }

  List<String> generateTimeRanges(List<Map<String, String>> matches, String videoDuration) {
    List<String> timeRanges = [];
    String previousEnd = "00:00:00.000";

    for (var match in matches) {
      List<String> times = match['time']!.split(' --> ');
      String startTime = times[0].replaceAll(',', '.');
      String endTime = times[1].replaceAll(',', '.');

      if (previousEnd != startTime) {
        timeRanges.add('-ss $previousEnd -to $startTime');
      }
      previousEnd = endTime;
    }

    if (previousEnd != videoDuration) {
      timeRanges.add('-ss $previousEnd -to $videoDuration');
    }

    return timeRanges;
  }

   Future<void> executeFFmpegCommands(List<String> timeRanges) async {
    List<String> tempFiles = [];

    for (var i = 0; i < timeRanges.length; i++) {
      String tempFileName = 'output_part_$i.ts';
      String cmd = '-i $_videoPath ${timeRanges[i]} -c copy -bsf:v h264_mp4toannexb -f mpegts $tempFileName';
      String result = await FFmpegHandler.executeFFmpeg(cmd.split(' '));
      print(result);
      if (File(tempFileName).existsSync()) {
        tempFiles.add(tempFileName);
      } else {
        print('临时文件创建失败: $tempFileName');
      }
    }

    await mergeVideoSegments(tempFiles);
    await cleanUpTempFiles(tempFiles);
  }

  Future<void> mergeVideoSegments(List<String> tempFiles) async {
    String concatFileName = 'concat_list.txt';
    File concatFile = File(concatFileName);
    await concatFile.writeAsString(tempFiles.map((f) => "file '$f'").join('\n'));

    String videoDir = File(_videoPath).parent.path;
    String videoName = File(_videoPath).uri.pathSegments.last;
    String outputFileName = '$videoDir/${videoName.split('.').first}_消音后.${videoName.split('.').last}';

    // 检查输出文件是否存在，如果存在则删除
    File outputFile = File(outputFileName);
    if (await outputFile.exists()) {
      await outputFile.delete();
    }

    String concatCmd = '-f concat -safe 0 -i $concatFileName -c copy $outputFileName';
    String concatResult = await FFmpegHandler.executeFFmpeg(concatCmd.split(' '));
    print(concatResult);

    concatFile.deleteSync();
  }


  Future<void> cleanUpTempFiles(List<String> tempFiles) async {
    for (var tempFile in tempFiles) {
      try {
        File(tempFile).deleteSync();
      } catch (e) {
        print('删除临时文件时发生错误: $e');
      }
    }
  }

  void runCensorship() async {
    if (_subtitlePath.isEmpty || _videoPath.isEmpty) {
      print('请确保视频和字幕文件已选择！');
      return;
    }

    if (_bannedWords.isEmpty) {
      print('请输入违规词！');
      return;
    }

    try {
      List<Map<String, String>> matches = await matchBannedWords();
      setState(() {
        _matches = matches;
      });

    String videoDuration = await getVideoDuration();
      List<String> timeRanges = generateTimeRanges(matches,videoDuration);
      print(timeRanges);

      await executeFFmpegCommands(timeRanges);

    } catch (e) {
      print('运行过程中发生错误: $e');
    }
  }
   Future<String> getVideoDuration() async {
    String cmd = '-i $_videoPath';
    String result = await FFmpegHandler.executeFFmpeg(cmd.split(' '));
    RegExp exp = RegExp(r'Duration: (\d+:\d+:\d+\.\d+)');
    Match? match = exp.firstMatch(result);
    if (match != null) {
      return match.group(1)!.replaceAll(',', '.');
    }
    throw Exception('无法获取视频时长');
  }
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) {
        for (var file in details.files) {
          if (file.path.endsWith('.srt')) {
            setState(() => _subtitlePath = file.path);
          } else if (file.path.endsWith('.mp4') || file.path.endsWith('.avi')) {
            setState(() => _videoPath = file.path);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('违规词消音'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: '输入需要消音的文本（一行一个违规词）',
                  hintText: '输入违规词',
                  border: OutlineInputBorder(),  // 添加外边框
                ),
                onChanged: (value) {
                  _bannedWords = value;
                },
                maxLines: 5,
              ),
              const SizedBox(height: 20),
                ElevatedButton(
                onPressed: pickVideoFile,
                child: const Text('选择视频文件'),
              ),
              const SizedBox(height: 20),
              Text('选中的视频文件: $_videoPath'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickSubtitleFile,
                child: const Text('选择字幕文件 (.srt)'),
              ),
              const SizedBox(height: 20),
              Text('选中的字幕文件: $_subtitlePath'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: runCensorship,
                child: const Text('开始运行'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,  // 设置一个固定高度
                child: ListView.builder(
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('序号: ${_matches[index]['index']} -  时间段: ${_matches[index]['time']}'),
                      subtitle: Text('文本: ${_matches[index]['text']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
