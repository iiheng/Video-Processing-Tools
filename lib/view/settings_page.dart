import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _enableWakelock = false;

  @override
  void initState() {
    super.initState();
    _initWakelockState();
  }

  Future<void> _initWakelockState() async {
    // Directly setting the toggle based on Wakelock.enabled
    _enableWakelock = await Wakelock.enabled;
    setState(() {}); // Refresh the UI with the updated status
  }

  void _toggleWakelock(bool value) {
    setState(() {
      _enableWakelock = value;
      Wakelock.toggle(
          enable:
              _enableWakelock); // Enable or disable wakelock based on switch
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Text(
              '设置',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('是否保持设备不休眠'),
              value: _enableWakelock,
              onChanged: _toggleWakelock,
              subtitle: Text(_enableWakelock ? '已启用' : '已禁用'),
            ),
          ],
        ),
      ),
    );
  }
}
