import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';

import 'package:liuyao/utils/logger.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'schemas.dart';

class StoreService {
  late Realm realm;
  late SharedPreferences sharedPreferences;

  StoreService(List<SchemaObject> schemas) {
    final config = Configuration.local(schemas,
        schemaVersion: 3, // 当前最新的 schema 版本号
        migrationCallback: migrationCallback); // 使用统一的迁移回调函数);
    realm = Realm(config);

    SharedPreferences.getInstance().then((perfs) {
      sharedPreferences = perfs;
    });
  }
  // region sharedPreferences
  // 获取本地值
  dynamic getLocal(String key){
    if (sharedPreferences.containsKey(key)) {
      return sharedPreferences.get(key);
    }
    return null;
  }
  // 设置本地缓存 根据传入类型设置存储
  Future<dynamic> setLocal(String key, dynamic value) async{
    if (value is String) {
      await sharedPreferences.setString(key, value);
    } else if (value is int) {
      await sharedPreferences.setInt(key, value);
    } else if (value is bool) {
      await sharedPreferences.setBool(key, value);
    } else if (value is double) {
      await sharedPreferences.setDouble(key, value);
    } else if (value is List<String>) {
      await sharedPreferences.setStringList(key, value);
    } else {
      throw Exception("Unsupported value type");
    }
  }
  // endregion
  // region realm
  // 添加或更新对象
  void update<T extends RealmObject>(T item) {
    realm.write(() {
      realm.add(item, update: true);
    });
  }

  // 获取所有对象
  List<T> getAll<T extends RealmObject>() {
    return realm.all<T>().toList();
  }

  // 根据主键获取对象
  T? getById<T extends RealmObject>(Uuid id) {
    return realm.find<T>(id);
  }

  // 删除对象
  void delete<T extends RealmObject>(T item) {
    realm.write(() {
      realm.delete(item);
    });
  }

  // 根据主键删除对象
  void deleteById<T extends RealmObject>(Uuid id) {
    final item = getById<T>(id);
    if (item != null) {
      delete(item);
    }
  }

  //删除全部数据
  void deleteAll<T extends RealmObject>() {
    realm.write(() {
      realm.deleteAll<T>();
    });
  }

  // 查询对象
  List<T> query<T extends RealmObject>(String query) {
    return realm.all<T>().query(query).toList();
  }

  // 关闭 Realm 实例
  void close() {
    realm.close();
  }
  // endregion
}

void migrationCallback(Migration migration, int oldSchemaVersion) {
  final newRealm = migration.newRealm;
  final oldRealm = migration.oldRealm;

  // 0-1
  if (oldSchemaVersion < 1) {
    // 处理从版本 0 到版本 1 的迁移逻辑，例如将 DateTime 转为时间戳
    final oldHistoryItems = oldRealm.all('HistoryItem');
    for (var oldItem in oldHistoryItems) {
      final newItem = newRealm.find<HistoryItem>(oldItem.dynamic.get('id'));
      if (newItem != null && oldItem is HistoryItem) {
        newItem.timestamp =
            (oldItem.timestamp as DateTime).millisecondsSinceEpoch;
      }
    }
    logger.info("处理数据库迁移升级");
  }
  // 1-2
  if (oldSchemaVersion < 2) {
    // 不需要调整
  }
  // 2-3
  if (oldSchemaVersion < 3) {}
}
