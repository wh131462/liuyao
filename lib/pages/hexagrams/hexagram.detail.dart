import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liuyao/components/page_scaffold.dart';
import 'package:liuyao/constants/xiang.dictionary.dart';

import '../../constants/liuyao.const.dart';

class HexagramDetailPage extends StatelessWidget {
  final Xiang hexagram;

  const HexagramDetailPage({super.key, required this.hexagram});

  @override
  Widget build(BuildContext context) {
    XiangDicItem detail = hexagram.getGuaProps();
    return PageScaffold(
      canBack: true,
      title: "第${hexagram.idx}卦 - ${hexagram.name} - ${hexagram.getGuaListText()}",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(detail.getFullRichText()),
        ),
      ),
    );
  }
}
