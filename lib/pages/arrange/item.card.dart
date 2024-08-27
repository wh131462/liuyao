import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:liuyao_flutter/constants/liuyao.const.dart';
import 'package:liuyao_flutter/pages/arrange/arrange.detail.dart';
import 'package:liuyao_flutter/utils/liuyao.util.dart';
import 'package:flutter/material.dart';
import 'package:liuyao_flutter/store/schemas.dart';

class HistoryItemCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onDelete;

  HistoryItemCard({required this.item,required this.onDelete});

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  // 假设有一个方法可以根据 originAnswer 获取卦象的名称和符号
  String _getHexagramName(String answer) {
    Map<Hexagram, Xiang> map = LiuYaoUtil.getHexagramsByText(answer);
    var origin = map[Hexagram.original]?.getGuaProps().name ?? "无";
    var transformed = map[Hexagram.transformed]?.getGuaProps().name ?? "无";
    return "$origin->$transformed"; // 示例返回值，需替换为实际逻辑
  }

  String _getHexagramSymbol(String answer) {
    Map<Hexagram, Xiang> map = LiuYaoUtil.getHexagramsByText(answer);
    return map[Hexagram.original]?.getSymbolText() ?? ""; // 获取本卦符号
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArrangeDetailPage(
              question: item.question,
              answer: item.originAnswer,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '问题: ${item.question.length>0?item.question:"未指定问题"}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.black54),
                    onPressed: (){
                      onDelete();
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '答: ${_getHexagramName(item.originAnswer)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(padding:EdgeInsets.only(right:14), child: Text(
                    _getHexagramSymbol(item.originAnswer),
                    style: TextStyle(fontSize: 24, height: 0.9, fontWeight: FontWeight.bold, color: Colors.blue),
                  ))
                ],
              ),
              SizedBox(height: 8),
              Text(
                '时间: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(item.timestamp))}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
