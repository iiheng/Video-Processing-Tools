import 'dart:io';

class FFmpegHandler {
  // 执行FFmpeg命令的静态方法
  static Future<String> executeFFmpeg(List<String> arguments) async {
    try {
      // 调用系统的FFmpeg可执行文件
      ProcessResult result = await Process.run('assets/ffmpeg', arguments);
      // 处理输出结果
      String output = result.stdout + '\n' + result.stderr;
      return output + '\n' "运行结束";
    } catch (e) {
      // 发生错误时返回错误信息
      return "Error running FFmpeg command: $e";
    }
  }

  // 获取视频总时长的静态方法
  static Future<int> getVideoDuration(String videoPath) async {
    // 使用 FFmpeg 获取视频的元数据
    String output = await executeFFmpeg(['-i', videoPath, '-hide_banner']);

    // 使用正则表达式查找持续时间
    RegExp durationPattern = RegExp(r"Duration: (\d{2}):(\d{2}):(\d{2})\.\d{2}");
    Match? match = durationPattern.firstMatch(output);

    if (match != null) {
      // 将时、分、秒转换为整数
      int hours = int.parse(match.group(1)!);
      int minutes = int.parse(match.group(2)!);
      int seconds = int.parse(match.group(3)!);

      // 计算总秒数
      return hours * 3600 + minutes * 60 + seconds;
    } else {
      // 如果没有找到匹配的持续时间，抛出异常或返回错误
      throw Exception("Unable to find the duration of the video.");
    }
  }
}
