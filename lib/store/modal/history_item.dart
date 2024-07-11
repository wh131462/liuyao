import 'package:realm/realm.dart';

@RealmModel()
class HistoryItem{
  late int id;
  late String question;
  late String originAnswer;//数字
  late String userId;
  late int timestamp;
}