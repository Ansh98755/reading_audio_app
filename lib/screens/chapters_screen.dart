import 'package:flutter/material.dart';
import '../api_services/api_service.dart';
import '../models/models.dart';
import 'reading_screen.dart';
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Chapters',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<ChapterWithContents>>(
        future: _future,
        builder: (context, snapshot) {
          /// Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          /// Error
          if (snapshot.hasError) {
            return Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Error loading chapters:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _future = _api.fetchData();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          /// Empty
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No chapters found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          /// Success
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.chapter.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Type: ${item.chapter.type}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey, size: 28),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
