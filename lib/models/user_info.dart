class UserInfo {
  final String id;
  final String username;
  final String? passwd;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatarPath;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserInfo({
    required this.id,
    required this.username,
    this.passwd,
    this.name,
    this.email,
    this.phone,
    this.avatarPath,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  UserInfo copyWith({
    String? id,
    String? username,
    String? passwd,
    String? name,
    String? email,
    String? phone,
    String? avatarPath,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserInfo(
      id: id ?? this.id,
      username: username ?? this.username,
      passwd: passwd ?? this.passwd,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      id: map['id'],
      username: map['username'],
      passwd: map['passwd'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      avatarPath: map['avatar_path'],
      memo: map['memo'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwd': passwd,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_path': avatarPath,
      'memo': memo,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'UserInfo(id: $id, username: $username, email: $email, avatarPath: $avatarPath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo &&
        other.id == id &&
        other.username == username &&
        other.passwd == passwd &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.avatarPath == avatarPath &&
        other.memo == memo &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        passwd.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        avatarPath.hashCode ^
        memo.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 