// 定义 Yao 枚举
import 'dart:math';

import 'package:liuyao_flutter/constants/xiang.dictionary.dart';
enum Yao {
  yin("yin","阴"),
  yang("yang","阳");
  final String key;
  final String title;
  const Yao(this.key,this.title);
}

// 定义 Gua 枚举
enum Gua {
  qian("qian","乾","☰",[Yao.yang,Yao.yang,Yao.yang]),
  kun("kun","坤","☷",[Yao.yin,Yao.yin,Yao.yin]),
  zhen("zhen","震","☳",[Yao.yin,Yao.yin,Yao.yang]),
  gen("gen","艮","☶",[Yao.yang,Yao.yin,Yao.yin]),
  li("li","离","☲",[Yao.yang,Yao.yin,Yao.yang]),
  kan("kan","坎","☵",[Yao.yin,Yao.yang,Yao.yin]),
  dui("dui","兑","☱",[Yao.yin,Yao.yang,Yao.yang]),
  xun("xun","巽","☴",[Yao.yang,Yao.yang,Yao.yin]);

  final String key;
  final String name;
  final String symbol;
  final List<Yao> yaoList;

  const Gua(this.key, this.name,this.symbol,this.yaoList);
}
/// 本卦 === Original Hexagram
/// 变卦 === Transformed Hexagram
/// 错卦 === Reversed Hexagram
/// 互卦 === Mutual Hexagrams
/// 综卦 === Opposite Hexagram
// 定义 Xiang 枚举
enum Xiang {
  qianqian(1, "乾", [Gua.qian, Gua.qian]),
  kunkun(2, "坤", [Gua.kun, Gua.kun]),
  kanzhen(3, "屯", [Gua.kan, Gua.zhen]),
  genkan(4, "蒙", [Gua.gen, Gua.kan]),
  kanqian(5, "需", [Gua.kan, Gua.qian]),
  qiankan(6, "讼", [Gua.qian, Gua.kan]),
  kunkan(7, "师", [Gua.kun, Gua.kan]),
  kankun(8, "比", [Gua.kan, Gua.kun]),
  xunqian(9, "小畜", [Gua.xun, Gua.qian]),
  qiandui(10, "履", [Gua.qian, Gua.dui]),
  kunqian(11, "泰", [Gua.kun, Gua.qian]),
  qiankun(12, "否", [Gua.qian, Gua.kun]),
  qianli(13, "同人", [Gua.qian, Gua.li]),
  liqian(14, "大有", [Gua.li, Gua.qian]),
  kungen(15, "谦", [Gua.kun, Gua.gen]),
  zhenkun(16, "豫", [Gua.zhen, Gua.kun]),
  duizhen(17, "随", [Gua.dui, Gua.zhen]),
  genxun(18, "蛊", [Gua.gen, Gua.xun]),
  kundui(19, "临", [Gua.kun, Gua.dui]),
  xunkun(20, "观", [Gua.xun, Gua.kun]),
  lizhen(21, "噬嗑", [Gua.li, Gua.zhen]),
  genli(22, "贲", [Gua.gen, Gua.li]),
  genkun(23, "剥", [Gua.gen, Gua.kun]),
  kunzhen(24, "复", [Gua.kun, Gua.zhen]),
  qianzhen(25, "无妄", [Gua.qian, Gua.zhen]),
  genqian(26, "大畜", [Gua.gen, Gua.qian]),
  genzhen(27, "颐", [Gua.gen, Gua.zhen]),
  duixun(28, "大过", [Gua.dui, Gua.xun]),
  kankan(29, "坎", [Gua.kan, Gua.kan]),
  lili(30, "离", [Gua.li, Gua.li]),
  duigen(31, "咸", [Gua.dui, Gua.gen]),
  zhenxun(32, "恒", [Gua.zhen, Gua.xun]),
  qiangen(33, "遁", [Gua.qian, Gua.gen]),
  zhenqian(34, "大壮", [Gua.zhen, Gua.qian]),
  likun(35, "晋", [Gua.li, Gua.kun]),
  kunli(36, "明夷", [Gua.kun, Gua.li]),
  xunli(37, "家人", [Gua.xun, Gua.li]),
  lidui(38, "睽", [Gua.li, Gua.dui]),
  kangen(39, "蹇", [Gua.kan, Gua.gen]),
  zhenkan(40, "解", [Gua.zhen, Gua.kan]),
  gendui(41, "损", [Gua.gen, Gua.dui]),
  xunzhen(42, "益", [Gua.xun, Gua.zhen]),
  duiqian(43, "夬", [Gua.dui, Gua.qian]),
  qianxun(44, "姤", [Gua.qian, Gua.xun]),
  duikun(45, "萃", [Gua.dui, Gua.kun]),
  kunxun(46, "升", [Gua.kun, Gua.xun]),
  duikan(47, "困", [Gua.dui, Gua.kan]),
  kanxun(48, "井", [Gua.kan, Gua.xun]),
  duili(49, "革", [Gua.dui, Gua.li]),
  lixun(50, "鼎", [Gua.li, Gua.xun]),
  zhenzhen(51, "震", [Gua.zhen, Gua.zhen]),
  gengen(52, "艮", [Gua.gen, Gua.gen]),
  xungen(53, "渐", [Gua.xun, Gua.gen]),
  zhendui(54, "归妹", [Gua.zhen, Gua.dui]),
  zhenli(55, "丰", [Gua.zhen, Gua.li]),
  ligen(56, "旅", [Gua.li, Gua.gen]),
  xunxun(57, "巽", [Gua.xun, Gua.xun]),
  duidui(58, "兑", [Gua.dui, Gua.dui]),
  xunkan(59, "涣", [Gua.xun, Gua.kan]),
  kandui(60, "节", [Gua.kan, Gua.dui]),
  xundui(61, "中孚", [Gua.xun, Gua.dui]),
  zhengen(62, "小过", [Gua.zhen, Gua.gen]),
  kanli(63, "既济", [Gua.kan, Gua.li]),
  likan(64, "未济", [Gua.li, Gua.kan]);

  final int idx;
  final String name;
  final List<Gua> guaList;

  const Xiang(this.idx, this.name,this.guaList);
  /// 通过卦名获取到象
  static Xiang getXiangByTitle(String name){
    return Xiang.values.firstWhere((v)=>v.name==name);
  }
  /// 获取按顺序输出的象列表
  static List<Xiang>? getXiangList(){
    const list =  Xiang.values;
    list.sort((a,b)=>a.idx-b.idx);
    return list;
  }
  /// 获取随机象
  static Xiang getRandomXiang(){
    return Xiang.values[Random().nextInt(Xiang.values.length)];
  }
  /// 获取卦对应的符号列表
  List<String> getSymbolList(){
    return guaList.map((gua)=>gua.symbol).toList();
  }
  /// 获取卦象对应的属性
  XiangDicItem? getGuaProps(){
    return xiangDictionary[name];
  }
}

