import 'package:flutter/material.dart';
import 'package:liuyao/components/image_rich_text.dart';
import 'package:liuyao/constants/xiangs/index.dart';

class XiangDicItem {
  final String name;
  final String description;
  final String? judgment;
  final String? image;
  final String? element;
  final String? nature;
  final String? attribute;
  final String? luck;
  final List<String>? yaoTexts;

  const XiangDicItem({
    required this.name,
    required this.description,
    this.judgment,
    this.image,
    this.element,
    this.nature,
    this.attribute,
    this.luck,
    this.yaoTexts,
  });

  getFullRichText() {
    return '''
$name

卦辞：$description

${judgment != null ? '彖辞：$judgment\n' : ''}
${image != null ? '象辞：$image\n' : ''}
${element != null ? '五行：$element\n' : ''}
${nature != null ? '性质：$nature\n' : ''}
${attribute != null ? '特质：$attribute\n' : ''}
${luck != null ? '吉凶：$luck\n' : ''}

爻辞：
${yaoTexts?.asMap().entries.map((entry) {
    int index = entry.key;
    String text = entry.value;
    return '第${index + 1}爻：$text';
  }).join('\n') ?? ''}
''';
  }
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
  "兑": zeZeDui,
  "革": zeHuoGe,
  "随": zeleiSui,
  "大过": zeFengDaGuo,
  "困": zeShuiKun,
  "咸": zeShanXian,
  "萃": zeZiCui,
  "大有": tianHuoDaYou,
  "睽": zeHuoKui,
  "离": liLiLi,
  "噬嗑": huoLeiShiHe,
  "鼎": huoFengDing,
  "未济": liKanWeiJi,
  "旅": huoShanLv,
  "晋": huoDiJin,
  "大壮": leiTianDaZhuang,
  "归妹": leiZeGuiMei,
  "丰": zhenZeFeng,
  "震": zhenZhen,
  "恒": leiFengHeng,
  "解": leiShuiJie,
  "小过": leiFengXiaoGuo,
  "豫": leiDiYu,
  "小畜": fengTianXiaoXu,
  "中孚": fengLeiZhongFu,
  "家人": fengHuoJiaRen,
  "益": fengLeiYi,
  "巽": xunXun,
  "涣": fengZeHuan,
  "渐": fengShanJian,
  "观": fengDiGuan,
  "需": shuiTianXu,
  "节": zeFengJie,
  "既济": kanLiJiJi,
  "屯": shuiLeiZhun,
  "井": shuiFengJing,
  "坎": kanKanXiKan,
  "蹇": shanShuiJian,
  "比": shuiDiBi,
  "大畜": shanTianDaXu,
  "损": shanZeSun,
  "贲": shanHuoBi,
  "颐": shanLeiYi,
  "蛊": shanFengGu,
  "蒙": shanShuiMeng,
  "艮": genGen,
  "剥": shanDiBo,
  "泰": diTianTai,
  "临": diZeLin,
  "明夷": diHuoMingYi,
  "复": diLeiFu,
  "升": diZeSheng,
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
