import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class PowerBIReportScreen extends StatelessWidget {
  const PowerBIReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: const Text('Power BI Report'),
      ),
      url: 'https://app.powerbi.com/view?r=eyJrIjoiYjFjMjk0ZTYtY2VjNi00NjYxLTgwZDgtYjFlNjAxYTU2YTk3IiwidCI6IjJlZDU1NzRjLWY5YmEtNDQyNi05NjU4LWU0NzdhZDc0MzlkYiIsImMiOjR9',
      withJavascript: true,
      withZoom: true,
    );
  }
}
