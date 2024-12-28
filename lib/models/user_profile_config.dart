class UserProfileConfig {
  String? avatarPath;
  String? coverPath;
  String? nickname;
  String? signature;

  UserProfileConfig({
    this.avatarPath,
    this.coverPath,
    this.nickname,
    this.signature,
  });

  Map<String, dynamic> toJson() => {
    'avatarPath': avatarPath,
    'coverPath': coverPath,
    'nickname': nickname,
    'signature': signature,
  };

  factory UserProfileConfig.fromJson(Map<String, dynamic> json) {
    return UserProfileConfig(
      avatarPath: json['avatarPath'],
      coverPath: json['coverPath'],
      nickname: json['nickname'],
      signature: json['signature'],
    );
  }
} 