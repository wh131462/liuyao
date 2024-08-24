# realm
创建realm的模型，必须要进行模型注册和生成。
## 1. 注册模型
添加part
```dart 
// 在 schemas.dart 中 就要填写named.g.dart
part 'schemas.g.dart';
// 需要使用装饰器标记
@RealmModel()
class _Named{
  @PrimaryKey()
  late ObjectId id;// 传值也需要 使用对应的 ObjectId() Uuid 使用 Uuid.v4()
  late String name;
}

@RealmModel()
class _User{
  @PrimaryKey()
  late ObjectId id;// 传值也需要 使用对应的 ObjectId() Uuid 使用 Uuid.v4()
  late String name;
  late String memo;
}
```
生成文件
```shell
dart run realm generate
```