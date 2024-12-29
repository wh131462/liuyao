import 'package:flutter/material.dart';
import 'package:liuyao/components/page_scaffold.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/pages/hexagrams/hexagram.detail.dart';
import 'package:liuyao/utils/liuyao.util.dart';
import 'package:liuyao/models/divination_result.dart';

class ArrangeDetailPage extends StatefulWidget {
  final String question;
  final String answer;
  final DateTime dateTime;
  final List<int> yaoValues;

  const ArrangeDetailPage({
    Key? key,
    required this.question,
    required this.answer,
    required this.dateTime,
    required this.yaoValues,
  }) : super(key: key);

  @override
  _ArrangeDetailPageState createState() => _ArrangeDetailPageState();
}

class _ArrangeDetailPageState extends State<ArrangeDetailPage> {
  late DivinationResult _result;
  
  @override
  void initState() {
    super.initState();
    _initializeResult();
  }
  
  void _initializeResult() {
    final hexagrams = LiuYaoUtil.getHexagramsByText(widget.yaoValues.join());
    _result = DivinationResult(
      question: widget.question,
      dateTime: widget.dateTime,
      yaoValues: widget.yaoValues,
      hexagrams: hexagrams,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '排盘详情',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionSection(),
            const Divider(),
            _buildTimeSection(),
            const Divider(),
            _buildHexagramSection(),
            const Divider(),
            _buildAnalysisSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '求测事项',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(widget.question),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '时间信息',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text('公历：${_result.solar.toFullString()}'),
        Text('农历：${_result.lunar.toFullString()}'),
        Text('节气：${_result.solarTerm}'),
        Text('空亡：${_result.emptyGods}'),
        Text('神煞：${_result.spirits.join("、")}'),
      ],
    );
  }

  Widget _buildHexagramSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '卦象信息',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _buildHexagramDetail(Hexagram.original, '本卦'),
        _buildHexagramDetail(Hexagram.transformed, '变卦'),
        _buildHexagramDetail(Hexagram.mutual, '互卦'),
        _buildHexagramDetail(Hexagram.reversed, '错卦'),
        _buildHexagramDetail(Hexagram.opposite, '综卦'),
      ],
    );
  }

  Widget _buildHexagramDetail(Hexagram type, String label) {
    final xiang = _result.hexagrams[type];
    if (xiang == null) return const SizedBox();
    
    return Card(
      child: ListTile(
        title: Text('$label：${xiang.getGuaProps().name}'),
        subtitle: Text(xiang.getGuaProps().description),
        onTap: () {
          // TODO: 导航到卦象详情页
        },
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '卦象分析',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _buildYaoAnalysis(),
        const SizedBox(height: 16),
        _buildWorldResponseAnalysis(),
      ],
    );
  }

  Widget _buildYaoAnalysis() {
    return Column(
      children: List.generate(6, (index) {
        final yaoValue = widget.yaoValues[5 - index];
        return ListTile(
          title: Text('第${index + 1}爻'),
          subtitle: Text(_getYaoDescription(yaoValue)),
          trailing: Text(_result.getSixRelative(index)),
        );
      }),
    );
  }

  String _getYaoDescription(int value) {
    switch (value) {
      case 6: return '老阴 ⚋ 变阳';
      case 7: return '少阳 ⚊';
      case 8: return '少阴 ⚋';
      case 9: return '老阳 ⚊ 变阴';
      default: return '未知';
    }
  }

  Widget _buildWorldResponseAnalysis() {
    final worldResponse = _result.getWorldResponse();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('世应分析', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('世爻：第${worldResponse['world']}爻'),
            Text('应爻：第${worldResponse['response']}爻'),
          ],
        ),
      ),
    );
  }
}