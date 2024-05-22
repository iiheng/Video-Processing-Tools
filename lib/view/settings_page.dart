import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/progress_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    ProgressProvider progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '设置',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              const Text(
                '调整进度条',
                style: TextStyle(fontSize: 16),
              ),
              Slider(
                value: progressProvider.progress,
                min: 0,
                max: 1,
                divisions: 100,
                label: progressProvider.progress.toStringAsFixed(2),
                onChanged: (double value) {
                  progressProvider.showProgress(value);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => progressProvider.showProgress(progressProvider.progress),
                child: const Text('显示进度条'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => progressProvider.hideProgress(),
                child: const Text('隐藏进度条'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
