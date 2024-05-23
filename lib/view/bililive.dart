import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class BililivePage extends StatefulWidget {
  const BililivePage({Key? key}) : super(key: key);

  @override
  _BililivePageState createState() => _BililivePageState();
}

class _BililivePageState extends State<BililivePage> {
  final _controller = WebviewController();
  bool _isLoading = true;
  Process? _bililiveProcess;

  @override
  void initState() {
    super.initState();
    runExecutableAndLoadPage();
  }

  Future<void> runExecutableAndLoadPage() async {
    _bililiveProcess =
        await Process.start('assets/bililive-windows-amd64.exe', []);
    // 初始化并加载 localhost 页面
    await _controller.initialize();
    await _controller.loadUrl('http://localhost:8080');
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiliLive'),
      ),
      body: Stack(
        children: <Widget>[
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Webview(_controller),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _bililiveProcess?.kill(); // 关闭页面时终止 exe 进程
    super.dispose();
  }
}
