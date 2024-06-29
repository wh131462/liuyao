// 定义 Yao 枚举
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
  qianqian("乾",[Gua.qian,Gua.qian]),
  kunkun("坤",[Gua.kun,Gua.kun]),
  kanzhen("屯",[Gua.kan, Gua.zhen]),
  genkan("蒙",[Gua.gen, Gua.kan]),
  kanqian("需",[Gua.kan, Gua.qian]),
  qiankan("讼",[Gua.qian, Gua.kan]),
  kunkan("师",[Gua.kun, Gua.kan]),
  kankun("比",[Gua.kan, Gua.kun]),
  xunqian("小畜",[Gua.xun, Gua.qian]),
  qiandui("履",[Gua.qian, Gua.dui]),
  kunqian("泰",[Gua.kun, Gua.qian]),
  qiankun("否",[Gua.qian, Gua.kun]),
  qianli("同人",[Gua.qian, Gua.li]),
  liqian("大有",[Gua.li, Gua.qian]),
  kungen("谦",[Gua.kun, Gua.gen]),
  zhenkun("豫",[Gua.zhen, Gua.kun]),
  duizhen("随",[Gua.dui, Gua.zhen]),
  genxun("蛊",[Gua.gen, Gua.xun]),
  kundui("临",[Gua.kun, Gua.dui]),
  xunkun("观",[Gua.xun, Gua.kun]),
  lizhen("噬嗑",[Gua.li, Gua.zhen]),
  genli("贲",[Gua.gen, Gua.li]),
  genkun("剥",[Gua.gen, Gua.kun]),
  kunzhen("复",[Gua.kun, Gua.zhen]),
  qianzhen("无妄",[Gua.qian, Gua.zhen]),
  genqian("大畜",[Gua.gen,Gua.qian]),
  genzhen("颐",[Gua.gen, Gua.zhen]),
  duixun("大过",[Gua.dui, Gua.xun]),
  kankan("坎",[Gua.kan, Gua.kan]),
  lili("离",[Gua.li, Gua.li]),
  duigen("咸",[Gua.dui, Gua.gen]),
  zhenxun("恒",[Gua.zhen, Gua.xun]),
  qiangen("遁",[Gua.qian, Gua.gen]),
  zhenqian("大壮",[Gua.zhen, Gua.qian]),
  likun("晋",[Gua.li, Gua.kun]),
  kunli("明夷",[Gua.kun, Gua.li]),
  xunli("家人",[Gua.xun, Gua.li]),
  lidui("睽",[Gua.li, Gua.dui]),
  kangen("蹇",[Gua.kan, Gua.gen]),
  zhenkan("解",[Gua.zhen, Gua.kan]),
  gendui("损",[Gua.gen, Gua.dui]),
  xunzhen("益",[Gua.xun, Gua.zhen]),
  duiqian("夬",[Gua.dui, Gua.qian]),
  qianxun("姤",[Gua.qian, Gua.xun]),
  duikun("萃",[Gua.dui, Gua.kun]),
  kunxun("升",[Gua.kun, Gua.xun]),
  duikan("困",[Gua.dui, Gua.kan]),
  kanxun("井",[Gua.kan, Gua.xun]),
  duili("革",[Gua.dui, Gua.li]),
  lixun("鼎",[Gua.li, Gua.xun]),
  zhenzhen("震",[Gua.zhen, Gua.zhen]),
  gengen("艮",[Gua.gen, Gua.gen]),
  xungen("渐",[Gua.xun, Gua.gen]),
  zhendui("归妹",[Gua.zhen, Gua.dui]),
  zhenli("丰",[Gua.zhen,Gua.li]),
  ligen("旅",[Gua.li, Gua.gen]),
  xunxun("巽",[Gua.xun, Gua.xun]),
  duidui("兑",[Gua.dui, Gua.dui]),
  xunkan("涣",[Gua.xun, Gua.kan]),
  kandui("节",[Gua.kan, Gua.dui]),
  xundui("中孚",[Gua.xun, Gua.dui]),
  zhengen("小过",[Gua.zhen, Gua.gen]),
  kanli("既济",[Gua.kan, Gua.li]),
  likan("未济",[Gua.li, Gua.kan]);

  final String name;
  final List<Gua> guaList;

  const Xiang(this.name,this.guaList);
  /// 通过卦名获取到象
  static getXiangByTitle(String name){
    return Xiang.values.firstWhere((v)=>v.name==name);
  }
  /// 获取卦对应的符号列表
  getSymbolList(){
    return guaList.map((gua)=>gua.symbol).toList();
  }
  /// 获取卦象对应的属性
  getGuaProps(){
    return xiangDictionary[name];
  }
}

