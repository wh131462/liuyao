import 'package:realm/realm.dart';

part 'schemas.realm.dart';

/// User Modal
@RealmModel()
class _User {
  @PrimaryKey()
  late Uuid id;
  late String name;
  late String memo;
}

@RealmModel()
class _HistoryItem {
  @PrimaryKey()
  late Uuid id;// = Uuid.v4(); // 自动生成 UUID
  late String question;
  late String originAnswer; //数字
  late int order;
  late String? group = "none";
  late String userId;
  late int timestamp;// =DateTime.now().millisecondsSinceEpoch; // 自动生成时间戳; // 使用 Unix 时间戳
}
