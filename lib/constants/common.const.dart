import 'liuyao.const.dart';

enum TraditionalDirection{
  east("正东", Gua.zhen),
  south("正南", Gua.li),
  west("正西", Gua.dui),
  north("正北",Gua.kan),
  southeast("东南",Gua.xun),
  northeast("东北", Gua.gen),
  southwest("西南", Gua.kun),
  northwest("西北", Gua.qian),
  middle("中", null);

  final String name;
  final Gua? gua;
  const TraditionalDirection(this.name, this.gua);
}