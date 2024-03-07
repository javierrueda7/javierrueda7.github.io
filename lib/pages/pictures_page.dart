import 'package:flutter/material.dart';

class PicturesPage extends StatefulWidget {
  final List<dynamic> loteInfo;
  const PicturesPage({super.key, required this.loteInfo});

  @override
  State<PicturesPage> createState() => _PicturesPageState();
}

class _PicturesPageState extends State<PicturesPage> {
  List<dynamic> loteInfo = [];

  @override
  void initState() {
    super.initState();
    loteInfo = widget.loteInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(loteInfo[1]),
        backgroundColor: const Color.fromARGB(255, 86, 135, 109),
      ),
    );
  }
}
