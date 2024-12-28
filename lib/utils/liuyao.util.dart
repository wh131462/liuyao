import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:liuyao/constants/liuyao.const.dart';

class LiuYaoUtil {
  /// 字符串转数字数组
  static List<int> stringToIntList(String str) {
    RegExp exp = RegExp(r'\d');
    Iterable<RegExpMatch> matches = exp.allMatches(str);
    return matches.map((m) {
      return int.parse(m.group(0).toString());
    }).toList();
  }

  /// 根据数字获取爻原始列表 - 升序
  static List<Yao> getYaoListByNumberAsc(List<int> numList) {
    return numList.map((int num) => getYaoByNumber(num)).toList();
  }

  /// 获取变爻列表 - 升序
  static List<Yao> getTransformedYaoListByNumberAsc(List<int> numList) {
    return numList.map((int num) => getTransformedYaoByNumber(num)).toList();
  }

  /// 获取爻列表 - 降序
  static List<Yao> getYaoListByNumberDsc(List<int> numList) {
    return getYaoListByNumberAsc(numList).reversed.toList();
  }

  /// 获取变爻列表 - 降序
  static List<Yao> getTransformedYaoListByNumberDsc(List<int> numList) {
    return getTransformedYaoListByNumberAsc(numList).reversed.toList();
  }

  /// 获取所有卦列表
  static Map<Hexagram, Xiang> getHexagramsByText(String text) {
    List<int> numList = LiuYaoUtil.stringToIntList(text);
    Map<Hexagram, Xiang> map = {};
    map.addAll(
        {Hexagram.original: LiuYaoUtil.getOriginalHexagramByNumber(numList)});
    map.addAll(
        {Hexagram.transformed: LiuYaoUtil.getTransformedHexagramByNumber(numList)});
    map.addAll(
        {Hexagram.mutual: LiuYaoUtil.getMutualHexagramByNumber(numList)});
    map.addAll(
        {Hexagram.reversed: LiuYaoUtil.getReversedHexagramByNumber(numList)});
    map.addAll(
        {Hexagram.opposite: LiuYaoUtil.getOppositeHexagramByNumber(numList)});
    return map;
  }

  // region 本卦
  /// 获取本卦卦列表
  static List<Gua> getOriginalHexagramGuaListByNumber(List<int> numList) {
    // 确保输入列表长度正确
    if (numList.isEmpty) {
      throw ArgumentError('输入数字列表不能为空');
    }

    // 确保有足够的数字来生成卦象
    List<Yao> yaoList = getYaoListByNumberDsc(numList);
    if (yaoList.length < 6) {
      // 如果爻的数量不足，用阴爻补齐
      while (yaoList.length < 6) {
        yaoList.add(Yao.yin);
      }
    }

    try {
      // 获取上卦（前三爻）
      List<Yao> upperYao = yaoList.sublist(0, 3);
      Gua guaUp = Gua.getGuaByYaoList(upperYao);

      // 获取下卦（后三爻）
      List<Yao> lowerYao = yaoList.sublist(3, 6);
      Gua guaDown = Gua.getGuaByYaoList(lowerYao);

      return [guaUp, guaDown];
    } catch (e) {
      debugPrint('生成卦象失败: $e');
      // 返回默认卦象（坤卦）
      return [Gua.kun, Gua.kun];
    }
  }

  /// 获取本卦卦象
  static Xiang getOriginalHexagramByNumber(List<int> numList) {
    List<Gua> guaList = getOriginalHexagramGuaListByNumber(numList);
    return Xiang.getXiangByYaoList(guaList);
  }

  // endregion
  // region 变卦
  /// 获取变卦卦列表
  static List<Gua> getTransformedHexagramGuaListByNumber(List<int> numList) {
    List<Yao> yaoList = getTransformedYaoListByNumberDsc(numList);
    Gua guaUp = Gua.getGuaByYaoList(yaoList.getRange(0, 3).toList());
    Gua guaDown = Gua.getGuaByYaoList(yaoList.getRange(3, 6).toList());
    return [guaUp, guaDown];
  }

  /// 获取变卦卦象
  static Xiang getTransformedHexagramByNumber(List<int> numList) {
    List<Gua> guaList = getTransformedHexagramGuaListByNumber(numList);
    return Xiang.getXiangByYaoList(guaList);
  }

  // endregion
  // region 错卦
  /// 获取错卦卦列表
  static List<Gua> getReversedHexagramGuaListByNumber(List<int> numList) {
    List<Yao> yaoList =
        getYaoListByNumberDsc(numList).map((o) => o.getReversedYao()).toList();
    Gua guaUp = Gua.getGuaByYaoList(yaoList.getRange(0, 3).toList());
    Gua guaDown = Gua.getGuaByYaoList(yaoList.getRange(3, 6).toList());
    return [guaUp, guaDown];
  }

  /// 获取错卦卦象
  static Xiang getReversedHexagramByNumber(List<int> numList) {
    List<Gua> guaList = getReversedHexagramGuaListByNumber(numList);
    return Xiang.getXiangByYaoList(guaList);
  }

  // endregion
  // region 互卦
  /// 获取互卦卦列表
  static List<Gua> getMutualHexagramGuaListByNumber(List<int> numList) {
    List<Yao> yaoList = getYaoListByNumberDsc(numList);
    Gua guaUp = Gua.getGuaByYaoList(yaoList.getRange(2, 5).toList());
    Gua guaDown = Gua.getGuaByYaoList(yaoList.getRange(1, 4).toList());
    return [guaUp, guaDown];
  }

  /// 获取互卦卦象
  static Xiang getMutualHexagramByNumber(List<int> numList) {
    List<Gua> guaList = getMutualHexagramGuaListByNumber(numList);
    return Xiang.getXiangByYaoList(guaList);
  }

  // endregion
  // region 综卦
  /// 获取综卦卦列表
  static List<Gua> getOppositeHexagramGuaListByNumber(List<int> numList) {
    List<Yao> yaoList = getYaoListByNumberAsc(numList);
    Gua guaUp = Gua.getGuaByYaoList(yaoList.getRange(0, 3).toList());
    Gua guaDown = Gua.getGuaByYaoList(yaoList.getRange(3, 6).toList());
    return [guaUp, guaDown];
  }

  /// 获取综卦卦象
  static Xiang getOppositeHexagramByNumber(List<int> numList) {
    List<Gua> guaList = getOppositeHexagramGuaListByNumber(numList);
    return Xiang.getXiangByYaoList(guaList);
  }

  // endregion

  /// 通过数字获取爻
  static Yao getYaoByNumber(int num) {
    switch (num) {
      case 6:
      case 8:
        return Yao.yin;
      case 7:
      case 9:
        return Yao.yang;
      default:
        return Yao.yin;
    }
  }

  /// 获取变爻
  static Yao getTransformedYaoByNumber(int num) {
    switch (num) {
      case 8:
      case 9:
        return Yao.yin;
      case 6:
      case 7:
        return Yao.yang;
      default:
        return Yao.yin;
    }
  }

  // region 生成方法
  /// 生成爻
  static int generateYao() {
    List<int> yaoList = [6, 7, 8, 9];
    return yaoList[Random().nextInt(yaoList.length)];
  }

  /// 生成六爻
  static List<int> generateLiuYao() {
    List<int> list = [];
    // 生成6个爻
    for (int i = 0; i < 6; i++) {
      list.add(generateYao());
    }
    return list;
  }
// endregion
}
