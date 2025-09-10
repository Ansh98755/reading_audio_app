import 'dart:convert';

import 'package:flutter/material.dart';

class RawJsonScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const RawJsonScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(data);
    return Scaffold(
      appBar: AppBar(title: const Text('API Raw Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(pretty, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
      ),
    );
  }
}



