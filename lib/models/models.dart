class ChapterSummary
{
  final int id;
  final String title;
  final String type;

  const ChapterSummary({required this.id, required this.title, required this.type});

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    return ChapterSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
    );
  }
}

class WordAudio {
  final int id;
  final String word;
  final String audioUrl;

  const WordAudio({required this.id, required this.word, required this.audioUrl});

  factory WordAudio.fromJson(Map<String, dynamic> json) {
    return WordAudio(
      id: json['id'] as int,
      word: (json['word'] as String).toLowerCase(),
      audioUrl: json['audio'] as String,
    );
  }
}

class ReadingContent {
  final int id;
  final String title;
  final String content;
  final int sequenceNumber;
  final List<WordAudio> words;

  const ReadingContent({
    required this.id,
    required this.title,
    required this.content,
    required this.sequenceNumber,
    required this.words,
  });

  factory ReadingContent.fromJson(Map<String, dynamic> json) {
    final wordsJson = (json['words'] as List<dynamic>? ?? []);
    return ReadingContent(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      sequenceNumber: json['sequence_number'] as int,
      words: wordsJson.map((e) => WordAudio.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ChapterWithContents {
  final ChapterSummary chapter;
  final List<ReadingContent> readingContents;

  const ChapterWithContents({required this.chapter, required this.readingContents});

  factory ChapterWithContents.fromJson(Map<String, dynamic> json) {
    return ChapterWithContents(
      chapter: ChapterSummary.fromJson(json['chapter'] as Map<String, dynamic>),
      readingContents: (json['reading_contents'] as List<dynamic>)
          .map((e) => ReadingContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}



