import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PowerBIReportScreen extends StatelessWidget {
  const PowerBIReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power BI Report'),
      ),
      body: const WebView(
        initialUrl: 'https://app.powerbi.com/view?r=eyJrIjoiYjFjMjk0ZTYtY2VjNi00NjYxLTgwZDgtYjFlNjAxYTU2YTk3IiwidCI6IjJlZDU1NzRjLWY5YmEtNDQyNi05NjU4LWU0NzdhZDc0MzlkYiIsImMiOjR9',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

