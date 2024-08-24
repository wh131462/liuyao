import 'package:liuyao_flutter/utils/logger.dart';
import 'package:realm/realm.dart';

import 'schemas.dart';

class StoreService {
  late Realm realm;

  StoreService(List<SchemaObject> schemas) {
    final config = Configuration.local(schemas,
        schemaVersion: 2, // 当前最新的 schema 版本号
        migrationCallback: migrationCallback); // 使用统一的迁移回调函数);
    realm = Realm(config);
  }

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
  T? getById<T extends RealmObject>(ObjectId id) {
    return realm.find<T>(id);
  }

  // 删除对象
  void delete<T extends RealmObject>(T item) {
    realm.write(() {
      realm.delete(item);
    });
  }

  // 根据主键删除对象
  void deleteById<T extends RealmObject>(ObjectId id) {
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
}

void migrationCallback(Migration migration, int oldSchemaVersion) {
  final newRealm = migration.newRealm;
  final oldRealm = migration.oldRealm;

  // 针对旧版本的迁移逻辑
  if (oldSchemaVersion < 1) {
    // 处理从版本 0 到版本 1 的迁移逻辑，例如将 DateTime 转为时间戳
    final oldHistoryItems = oldRealm.all('HistoryItem');
    for (var oldItem in oldHistoryItems) {
      final newItem = newRealm.find<HistoryItem>(oldItem.dynamic.get('id'));
      if (newItem != null && oldItem is HistoryItem) {
        newItem.timestamp = (oldItem.timestamp as DateTime).millisecondsSinceEpoch;
      }
    }
    logger.info("处理数据库迁移升级");
  }

  if (oldSchemaVersion < 2) {
    // 处理版本 1 到版本 2 的迁移，例如新增或删除字段
    // 这里可以添加更多的迁移逻辑
  }
}
