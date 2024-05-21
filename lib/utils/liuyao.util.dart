import 'dart:math';
class LiuYaoUtil{
  static int generateYao(){
    List<int> yaoList = [6,7,8,9];
    return yaoList[Random().nextInt(yaoList.length)];
  }
}