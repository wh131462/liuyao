class HistoryItem {
  final String id;
  final String question;
  final String originAnswer;
  final String? note;
  final int timestamp;
  final String? analysis;
  final String? conclusion;
  final String? tags;

  HistoryItem({
    required this.id,
    required this.question,
    required this.originAnswer,
    this.note,
    required this.timestamp,
    this.analysis,
    this.conclusion,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'origin_answer': originAnswer,
      'note': note,
      'timestamp': timestamp,
      'analysis': analysis,
      'conclusion': conclusion,
      'tags': tags,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      question: map['question'] ?? '',
      originAnswer: map['origin_answer'] ?? '',
      note: map['note'],
      timestamp: map['timestamp'],
      analysis: map['analysis'],
      conclusion: map['conclusion'],
      tags: map['tags'],
    );
  }

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(timestamp);

  List<String> get tagList => tags?.split(',').map((e) => e.trim()).toList() ?? [];

  HistoryItem copyWith({
    String? question,
    String? originAnswer,
    String? note,
    int? timestamp,
    String? analysis,
    String? conclusion,
    String? tags,
  }) {
    return HistoryItem(
      id: this.id,
      question: question ?? this.question,
      originAnswer: originAnswer ?? this.originAnswer,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      analysis: analysis ?? this.analysis,
      conclusion: conclusion ?? this.conclusion,
      tags: tags ?? this.tags,
    );
  }
} 