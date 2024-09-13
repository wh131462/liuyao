import 'package:liuyao/constants/common.const.dart';

/// 小六壬宫位
enum XiaoLiuRen {
  daan("大安", "长期 缓慢 稳定", "木", TraditionalDirection.east, "三清", 1),
  liulian("留连", "停止 反复 复杂", "木", TraditionalDirection.southwest, "文昌", 2),
  suxi("速喜", "惊喜 快速 突然", "火", TraditionalDirection.south, "雷祖", 3),
  chikou("赤口", "争斗 凶恶 伤害", "金", TraditionalDirection.west, "将帅", 4),
  xiaoji("小吉", "起步 不多 尚可", "水", TraditionalDirection.north, "真武", 5),
  kongwang("空亡", "失去 虚伪 空想", "土", TraditionalDirection.middle, "玉皇", 6),
  bingfu("病符", "病态 异常 治疗", "金", TraditionalDirection.southwest, "后土", 7),
  taohua("桃花", "欲望 牵绊 异性", "土", TraditionalDirection.northeast, "城隍", 8),
  tiande("天德", "贵人 上司 高选", "金", TraditionalDirection.northwest, "紫微", 9);

  final String name;
  final String description;
  final String property;
  final TraditionalDirection direction;
  final String shen;
  final int order;

  const XiaoLiuRen(this.name, this.description, this.property, this.direction,
      this.shen, this.order);

  /// 获取第一个
  static XiaoLiuRen getFirst() {
    return XiaoLiuRen.daan;
  }

  /// 获取按序小六壬
  static List<XiaoLiuRen> getXiaoLiuRenListByOrder() {
    var list = List<XiaoLiuRen>.from(XiaoLiuRen.values);
    list.sort((a, b) => a.order - b.order);
    return list;
  }

  /// 通过index获取
  static XiaoLiuRen getXiaoLiuRenByOrder(int order) {
    return XiaoLiuRen.values.where((e) => e.order == order).first;
  }

  /// 从起始六壬走步数
  static XiaoLiuRen getXiaoLiuRenByStep(XiaoLiuRen from, int step) {
    if (step == 0) return from;
    int first = ((from.order - 1) + (step % 10)) % 10;
    int target = first == 0 ? 1 : first;
    return getXiaoLiuRenByOrder(target);
  }
}
