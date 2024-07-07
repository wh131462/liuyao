class HistoryItem{
  final int id;
  final String question;
  final String originAnswer;

  const HistoryItem({
    required this.id,
    required this.question,
    required this.originAnswer,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'question': question,
      'originAnswer': originAnswer,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Dog{id: $id, name: $question, age: $originAnswer}';
  }
}