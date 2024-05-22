import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '帮助',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                '本软件免费，需要讨论请进入下群沟通。',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'QQ群: 853735619', // 这里填写实际的QQ号
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                '有任何问题和使用的建议，都可通过上方qq群联系作者。',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
