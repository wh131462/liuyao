import 'package:realm/realm.dart';
/// 基础Store类
abstract class Store<T extends RealmObject> {
  final Realm _realm;

  Store(this._realm);

  // 保存单个对象
  Future<T?> save(T object) async {
    try {
      await _realm.write(() {
        _realm.add(object);
      });
      return object;
    } catch (e) {
      print('Error saving object: $e');
      return null;
    }
  }

  // 批量保存对象
  Future<List<T>?> saveAll(List<T> objects) async {
    try {
      await _realm.write(() {
        _realm.addAll(objects);
      });
      return objects;
    } catch (e) {
      print('Error saving objects: $e');
      return null;
    }
  }

  // 获取所有对象
  Future<List<T>> getAll({int page = 0, int pageSize = 10}) async {
    // Calculate the range for pagination
    int startIndex = page * pageSize;
    int endIndex = startIndex + pageSize;
    return _realm.all<T>().toList().getRange(startIndex, endIndex).toList();
  }

  // 根据条件过滤对象
  Future<List<RealmObject>> query(String query) async {
    var results = _realm.query(query);
    return results.toList();
  }

  // 根据ID获取对象
  Future<T?> getById(int id) async {
    return _realm.find<T>(id);
  }

  // 更新对象
  Future<T?> update(T object) async {
    try {
      await _realm.write(() {
        _realm.add(object,update: true);
      });
      return object;
    } catch (e) {
      print('Error updating object: $e');
      return null;
    }
  }

  // 删除单个对象
  Future<void> delete(T object) async {
    await _realm.write(() {
      _realm.delete(object);
    });
  }

  // 批量删除对象
  Future<void> deleteItems(List<T> objects) async {
    _realm.write(() {
      _realm.deleteMany(objects);
    });
  }

  // 删除全部对象
  Future<void> deleteAll() async {
    _realm.write(() {
      _realm.deleteAll<T>();
    });
  }
}