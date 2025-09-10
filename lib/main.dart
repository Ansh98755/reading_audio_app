import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'reading_screen.dart';
import 'raw_json_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading Audio App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const ChaptersScreen(),
    );
  }
}

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  final ApiService _api = ApiService();
  late Future<List<ChapterWithContents>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapters')),
      body: FutureBuilder<List<ChapterWithContents>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('No chapters found'));
          }
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                title: Text('Chapter ${index + 1}: ${item.chapter.title}'),
                subtitle: Text('Type: ${item.chapter.type}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReadingScreen(
                        chapterTitle: item.chapter.title,
                        contents: item.readingContents,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final raw = await _api.fetchRaw();
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RawJsonScreen(data: raw)),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load raw: $e')),
            );
          }
        },
        child: const Icon(Icons.data_object),
      ),
    );
  }
}
