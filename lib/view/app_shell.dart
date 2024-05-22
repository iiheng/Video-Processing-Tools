import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/progress_provider.dart';

class AppShell extends StatelessWidget {
  final Widget page;
  const AppShell({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var progressProvider = Provider.of<ProgressProvider>(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          page,
          Align(
            alignment: Alignment.topCenter,
            child: progressProvider.isVisible ? LinearProgressIndicator(value: progressProvider.progress) : const SizedBox(height: 0),
          ),
        ],
      ),
    );
  }
}
