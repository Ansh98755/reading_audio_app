import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class ReadingScreen extends StatefulWidget {
  final String chapterTitle;
  final List<ReadingContent> contents;

  const ReadingScreen({super.key, required this.chapterTitle, required this.contents});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final AudioPlayer _player = AudioPlayer();
  final Map<String, String> _urlToLocalPath = {};
  late List<ReadingContent> _contents;
  final ApiService _api = ApiService();

  static const String _audioBase = 'https://api-ten-delta-32.vercel.app/';

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (_audioBase.endsWith('/') && url.startsWith('/')) {
      return _audioBase + url.substring(1);
    }
    if (!_audioBase.endsWith('/') && !url.startsWith('/')) {
      return _audioBase + '/' + url;
    }
    return _audioBase + url;
  }

  @override
  void initState() {
    super.initState();
    _contents = List<ReadingContent>.from(widget.contents);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<String> _ensureLocalFile(String url) async {
    final resolved = _resolveUrl(url);
    if (_urlToLocalPath.containsKey(resolved)) {
      return _urlToLocalPath[resolved]!;
    }
    final tempDir = await getTemporaryDirectory();
    final fileName = resolved.hashCode.toString();
    final file = File('${tempDir.path}/$fileName');
    try {
      final resp = await http.get(Uri.parse(resolved));
      if (resp.statusCode == 200) {
        await file.writeAsBytes(resp.bodyBytes);
        _urlToLocalPath[resolved] = file.path;
        return file.path;
      } else {
        throw HttpException('HTTP ${resp.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _refreshContents() async {
    final data = await _api.fetchData();
    final found = data.firstWhere(
      (c) => c.chapter.title == widget.chapterTitle,
      orElse: () => ChapterWithContents(
        chapter: ChapterSummary(id: -1, title: widget.chapterTitle, type: ''),
        readingContents: _contents,
      ),
    );
    setState(() {
      _contents = found.readingContents;
      _urlToLocalPath.clear();
    });
  }

  Future<void> _playForWord(String word, List<WordAudio> words, {bool retried = false}) async {
    final lower = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final match = words.firstWhere(
      (w) => w.word == lower,
      orElse: () => const WordAudio(id: -1, word: '', audioUrl: ''),
    );
    if (match.audioUrl.isNotEmpty) {
      try {
        await _player.stop();
        // Download then play locally to avoid streaming issues on some devices
        final localPath = await _ensureLocalFile(match.audioUrl);
        await _player.play(DeviceFileSource(localPath));
      } catch (e) {
        final is403 = e is HttpException && e.message.contains('403');
        if (is403 && !retried) {
          // Refresh data to get fresh signed URLs, then retry once
          await _refreshContents();
          // Find the updated word mapping and retry
          final updated = _contents.firstWhere(
            (rc) => rc.words.any((w) => w.word == lower),
            orElse: () => ReadingContent(id: -1, title: '', content: '', sequenceNumber: 0, words: words),
          );
          await _playForWord(word, updated.words, retried: true);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapterTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _contents.length,
        itemBuilder: (context, index) {
          final item = _contents[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        child: Text('${item.sequenceNumber}'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    children: item.content.split(' ').map((token) {
                      final cleaned = token.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
                      final hasAudio = item.words.any((w) => w.word == cleaned);
                      return GestureDetector(
                        onTap: hasAudio ? () => _playForWord(token, item.words) : null,
                        child: Text(
                          '$token ',
                          style: TextStyle(
                            color: hasAudio ? Colors.indigo : null,
                            decoration: hasAudio ? TextDecoration.underline : TextDecoration.none,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text('Reading ID: ${item.id}  | Seq: ${item.sequenceNumber}', style: Theme.of(context).textTheme.bodySmall),
                  if (item.title.isNotEmpty)
                    Text('Title: ${item.title}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text('Words:', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.words.map((w) {
                      return Chip(
                        label: Text(w.word),
                        onDeleted: null,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


