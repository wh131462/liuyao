// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class UserInfo extends _UserInfo
    with RealmEntity, RealmObjectBase, RealmObject {
  UserInfo(
    Uuid id, {
    String? username,
    String? passwd,
    String? name,
    String? memo,
    String? email,
    String? phone,
    DateTime? createTime,
    DateTime? lastModified,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'username', username);
    RealmObjectBase.set(this, 'passwd', passwd);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'memo', memo);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'createTime', createTime);
    RealmObjectBase.set(this, 'lastModified', lastModified);
  }

  UserInfo._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get username =>
      RealmObjectBase.get<String>(this, 'username') as String?;
  @override
  set username(String? value) => RealmObjectBase.set(this, 'username', value);

  @override
  String? get passwd => RealmObjectBase.get<String>(this, 'passwd') as String?;
  @override
  set passwd(String? value) => RealmObjectBase.set(this, 'passwd', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get memo => RealmObjectBase.get<String>(this, 'memo') as String?;
  @override
  set memo(String? value) => RealmObjectBase.set(this, 'memo', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get phone => RealmObjectBase.get<String>(this, 'phone') as String?;
  @override
  set phone(String? value) => RealmObjectBase.set(this, 'phone', value);

  @override
  DateTime? get createTime =>
      RealmObjectBase.get<DateTime>(this, 'createTime') as DateTime?;
  @override
  set createTime(DateTime? value) =>
      RealmObjectBase.set(this, 'createTime', value);

  @override
  DateTime? get lastModified =>
      RealmObjectBase.get<DateTime>(this, 'lastModified') as DateTime?;
  @override
  set lastModified(DateTime? value) =>
      RealmObjectBase.set(this, 'lastModified', value);

  @override
  Stream<RealmObjectChanges<UserInfo>> get changes =>
      RealmObjectBase.getChanges<UserInfo>(this);

  @override
  Stream<RealmObjectChanges<UserInfo>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<UserInfo>(this, keyPaths);

  @override
  UserInfo freeze() => RealmObjectBase.freezeObject<UserInfo>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'username': username.toEJson(),
      'passwd': passwd.toEJson(),
      'name': name.toEJson(),
      'memo': memo.toEJson(),
      'email': email.toEJson(),
      'phone': phone.toEJson(),
      'createTime': createTime.toEJson(),
      'lastModified': lastModified.toEJson(),
    };
  }

  static EJsonValue _toEJson(UserInfo value) => value.toEJson();
  static UserInfo _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        UserInfo(
          fromEJson(id),
          username: fromEJson(ejson['username']),
          passwd: fromEJson(ejson['passwd']),
          name: fromEJson(ejson['name']),
          memo: fromEJson(ejson['memo']),
          email: fromEJson(ejson['email']),
          phone: fromEJson(ejson['phone']),
          createTime: fromEJson(ejson['createTime']),
          lastModified: fromEJson(ejson['lastModified']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UserInfo._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, UserInfo, 'UserInfo', [
      SchemaProperty('id', RealmPropertyType.uuid, primaryKey: true),
      SchemaProperty('username', RealmPropertyType.string, optional: true),
      SchemaProperty('passwd', RealmPropertyType.string, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('memo', RealmPropertyType.string, optional: true),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('createTime', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('lastModified', RealmPropertyType.timestamp,
          optional: true),
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
    Uuid userId,
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
  Uuid get userId => RealmObjectBase.get<Uuid>(this, 'userId') as Uuid;
  @override
  set userId(Uuid value) => RealmObjectBase.set(this, 'userId', value);

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
      SchemaProperty('userId', RealmPropertyType.uuid),
      SchemaProperty('timestamp', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
