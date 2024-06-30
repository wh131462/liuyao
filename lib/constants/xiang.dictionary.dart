import 'package:liuyao_flutter/constants/xiangs/index.dart';

class XiangDicItem {
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

  XiangDicItem(this.name, this.fullName, this.simpleDescription,
      this.originalHexagram, this.initialLine, this.secondLine, this.thirdLine,
      this.fourthLine, this.fifthLine, this.uppermostLine);
}

/// 象表映射字典 象名为键名 象为值
Map<String, XiangDicItem> xiangDictionary = {
  "乾": qianWeiTian,
  "履": tianZeLv,
  "同人": tianHuoTongRen,
  "无妄": tianLeiWuWang,
  "姤": tianFengGou,
  "讼": tianShuiSong,
  "遁": tianShanDun,
  "否": tianDiPi,
  "夬": zeTianGuai,
  "兑": duiWeiZe,
  "革": zeHuoGe,
  "随": zeLeiSui,
  "大过": zeFengDaGuo,
  "困": zeShuiKun,
  "咸": zeShanXian,
  "萃": zeDiCui,
  "大有": tianHuoDaYou,
  "睽": huoZeKui,
  "离": liWeiHuo,
  "噬嗑":huoLeiSHiKe,
  "鼎": huoFengDing,
  "未济": huoShuiWeiJi,
  "旅": huoShanLv,
  "晋": huoDiJin,
  "大壮": leiTianDaZhuang,
  "归妹": leiZeGuiMei,
  "丰": leiHuoFeng,
  "震": zhenWeiLei,
  "恒": leiFengHeng,
  "解": leiShuiJie,
  "小过": leiShanXiaoGuo,
  "豫": leiDiYu,
  "小畜": fengTianXiaoChu,
  "中孚": fengZeZhongFu,
  "家人": fengHuoJiaRen,
  "益": fengLeiYi,
  "巽": xunWeiFeng,
  "涣": fengShuiHuan,
  "渐": fengShanJian,
  "观": fengDiGuan,
  "需": shuiTianXu,
  "节": shuiZeJie,
  "既济": shuiHuoJiJi,
  "屯": shuiLeiTun,
  "井": shuiFengJing,
  "坎": kanWeiShui,
  "蹇": shuiShanJian,
  "比": shuiDiBi,
  "大畜": shanTianDaChu,
  "损": shanZeSun,
  "贲": shanHuoBen,
  "颐": shanLeiYi,
  "蛊": shanFengGu,
  "蒙": shanShuiMeng,
  "艮": genWeiShan,
  "剥": shanDiBo,
  "泰": diTianTai,
  "临": diZeLin,
  "明夷": diHuoMingYi,
  "复": diLeiFu,
  "升": diFengSheng,
  "师": diShuiShi,
  "谦": diShanQian,
  "坤": kunWeiDi
};
// 网站勘误
// https://www.zhouyi.cc/zhouyi/yijing64/4257.html 原文
// https://www.zhouyi.cc/zhouyi/yijing64/4188.html 六四爻 结尾
// https://www.zhouyi.cc/zhouyi/yijing64/4179.html 九二
// https://www.zhouyi.cc/zhouyi/yijing64/4111.html 九初
// https://www.zhouyi.cc/zhouyi/yijing64/4159.html
// https://www.zhouyi.cc/zhouyi/yijing64/4126.html 泰卦变豫卦
