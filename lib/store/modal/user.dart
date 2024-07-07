class User {
  final int id;
  final String uid;
  final String name;
  final String headPic;
  final String gender;
  final String memo;

  User({
    required this.id,
    required this.uid,
    required this.name,
    required this.headPic,
    required this.gender,
    required this.memo,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'headPic': headPic,
      'gender': gender,
      'memo': memo
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'User{id: $id, uid: $uid, name: $name, headPic: $headPic}，gender: $gender,memo:$memo';
  }
}
