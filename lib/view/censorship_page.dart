import 'package:flutter/material.dart';

class CensorshipPage extends StatefulWidget {
  const CensorshipPage({Key? key}) : super(key: key);

  @override
  _CensorshipPageState createState() => _CensorshipPageState();
}

class _CensorshipPageState extends State<CensorshipPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('违规词消音'),
      ),
      body: const Center(
        child: Text(
          '这里是违规词消音功能的界面。',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
