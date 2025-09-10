import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiService {
  static const String _baseUrl = 'https://api-ten-delta-32.vercel.app/api/data';

  Future<List<ChapterWithContents>> fetchData() async {
    final uri = Uri.parse(_baseUrl);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> list = decoded['data'] as List<dynamic>;
    return list
        .map((e) => ChapterWithContents.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> fetchRaw() async {
    final uri = Uri.parse(_baseUrl);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }
}


