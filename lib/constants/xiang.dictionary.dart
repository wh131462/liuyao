import 'package:liuyao_flutter/constants/xiangs/qian_wei_tian.dart';

class XiangDicItem{
  // 象名称
  String name;
  // 象全名
  String fullName;
  // 象简述
  String simpleDescription;
  // 象的本卦原文
  String originalHexagram;
  // 象的初爻
  String initialLine;
  // 象的二爻
  String secondLine;
  // 象的三爻
  String thirdLine;
  // 象的四爻
  String fourthLine;
  // 象的五爻
  String fifthLine;
  // 象的上爻
  String uppermostLine;

  XiangDicItem(this.name,this.fullName,this.simpleDescription,this.originalHexagram,this.initialLine,this.secondLine,this.thirdLine,this.fourthLine,this.fifthLine,this.uppermostLine);
}
/// 象表映射字典 象名为键名 象为值
Map<String,XiangDicItem> xiangDictionary = {
  "乾":qianWeiTian,
};