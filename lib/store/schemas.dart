import 'package:realm/realm.dart';

part 'schemas.realm.dart';

/// User Modal
@RealmModel()
class _UserInfo {
  @PrimaryKey()
  late Uuid id;
  late String? username;
  late String? passwd;
  late String? name;
  late String? memo;
  // 新增字段
  late String? email;         // 用户的邮箱
  late String? phone;   // 用户的电话号码
  late DateTime? createTime;   // 用户创建时间
  late DateTime? lastModified;   // 用户更新时间
}

@RealmModel()
class _HistoryItem {
  @PrimaryKey()
  late Uuid id;// = Uuid.v4(); // 自动生成 UUID
  late String question;
  late String originAnswer; //数字
  late int order;
  late String? group = "none";
  late Uuid userId;
  late int timestamp;// =DateTime.now().millisecondsSinceEpoch; // 自动生成时间戳; // 使用 Unix 时间戳
}
