// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class User extends _User with RealmEntity, RealmObjectBase, RealmObject {
  User(
    Uuid id,
    String name,
    String memo,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'memo', memo);
  }

  User._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get memo => RealmObjectBase.get<String>(this, 'memo') as String;
  @override
  set memo(String value) => RealmObjectBase.set(this, 'memo', value);

  @override
  Stream<RealmObjectChanges<User>> get changes =>
      RealmObjectBase.getChanges<User>(this);

  @override
  Stream<RealmObjectChanges<User>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<User>(this, keyPaths);

  @override
  User freeze() => RealmObjectBase.freezeObject<User>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'memo': memo.toEJson(),
    };
  }

  static EJsonValue _toEJson(User value) => value.toEJson();
  static User _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'memo': EJsonValue memo,
      } =>
        User(
          fromEJson(id),
          fromEJson(name),
          fromEJson(memo),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(User._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, User, 'User', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('memo', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class HistoryItem extends _HistoryItem
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  HistoryItem(
    Uuid id,
    String question,
    String originAnswer,
    int order,
    String userId,
    int timestamp, {
    String? group = "none",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<HistoryItem>({
        'group': "none",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'question', question);
    RealmObjectBase.set(this, 'originAnswer', originAnswer);
    RealmObjectBase.set(this, 'order', order);
    RealmObjectBase.set(this, 'group', group);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'timestamp', timestamp);
  }

  HistoryItem._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get question =>
      RealmObjectBase.get<String>(this, 'question') as String;
  @override
  set question(String value) => RealmObjectBase.set(this, 'question', value);

  @override
  String get originAnswer =>
      RealmObjectBase.get<String>(this, 'originAnswer') as String;
  @override
  set originAnswer(String value) =>
      RealmObjectBase.set(this, 'originAnswer', value);

  @override
  int get order => RealmObjectBase.get<int>(this, 'order') as int;
  @override
  set order(int value) => RealmObjectBase.set(this, 'order', value);

  @override
  String? get group => RealmObjectBase.get<String>(this, 'group') as String?;
  @override
  set group(String? value) => RealmObjectBase.set(this, 'group', value);

  @override
  String get userId => RealmObjectBase.get<String>(this, 'userId') as String;
  @override
  set userId(String value) => RealmObjectBase.set(this, 'userId', value);

  @override
  int get timestamp => RealmObjectBase.get<int>(this, 'timestamp') as int;
  @override
  set timestamp(int value) => RealmObjectBase.set(this, 'timestamp', value);

  @override
  Stream<RealmObjectChanges<HistoryItem>> get changes =>
      RealmObjectBase.getChanges<HistoryItem>(this);

  @override
  Stream<RealmObjectChanges<HistoryItem>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<HistoryItem>(this, keyPaths);

  @override
  HistoryItem freeze() => RealmObjectBase.freezeObject<HistoryItem>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'question': question.toEJson(),
      'originAnswer': originAnswer.toEJson(),
      'order': order.toEJson(),
      'group': group.toEJson(),
      'userId': userId.toEJson(),
      'timestamp': timestamp.toEJson(),
    };
  }

  static EJsonValue _toEJson(HistoryItem value) => value.toEJson();
  static HistoryItem _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'question': EJsonValue question,
        'originAnswer': EJsonValue originAnswer,
        'order': EJsonValue order,
        'userId': EJsonValue userId,
        'timestamp': EJsonValue timestamp,
      } =>
        HistoryItem(
          fromEJson(id),
          fromEJson(question),
          fromEJson(originAnswer),
          fromEJson(order),
          fromEJson(userId),
          fromEJson(timestamp),
          group: fromEJson(ejson['group'], defaultValue: "none"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(HistoryItem._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, HistoryItem, 'HistoryItem', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('question', RealmPropertyType.string),
      SchemaProperty('originAnswer', RealmPropertyType.string),
      SchemaProperty('order', RealmPropertyType.int),
      SchemaProperty('group', RealmPropertyType.string, optional: true),
      SchemaProperty('userId', RealmPropertyType.string),
      SchemaProperty('timestamp', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
