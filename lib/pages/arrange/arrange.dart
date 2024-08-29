import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/pages/arrange/arrange.detail.dart';
import 'package:liuyao/store/schemas.dart';
import 'package:liuyao/utils/liuyao.util.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../store/store.dart';
import '../calendar/calendar.dart';
import 'arrange.history.dart';
import 'divination.input.dart';

class ArrangePage extends StatefulWidget {
  @override
  _ArrangePageState createState() => _ArrangePageState();
}

class _ArrangePageState extends State<ArrangePage> {
  final TextEditingController _numberEditingController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  late StoreService storeService;

  String generateRandomNumber() {
    const String possibleCharacters = '6789';
    const int length = 6;
    var random = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) {
      return possibleCharacters.codeUnitAt(random.nextInt(possibleCharacters.length));
    }));
  }

  void _navigateToResultPage() {
    if (_numberEditingController.text.isNotEmpty) {
      storeService.update<HistoryItem>(HistoryItem(Uuid.v4(), _textEditingController.text, _numberEditingController.text, 0, Uuid.v4(), DateTime.now().millisecondsSinceEpoch));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArrangeDetailPage(
            question: _textEditingController.text,
            answer: _numberEditingController.text,
          ),
        ),
      );
    }
  }

  void _cyberShake() {
    setState(() {
      _numberEditingController.text = generateRandomNumber();
    });
  }

  void _viewHistory() {
    // 处理查看历史记录的逻辑
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArrangeHistory(), // 请确保你有实现 HistoryPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    storeService = context.watch<StoreService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('六爻排盘'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(),  // 跳转到日历页面
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: '何惑？',
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),
            DivinationInput(numberEditingController: _numberEditingController,),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _cyberShake,
                  icon: Icon(Icons.shuffle),
                  label: Text('赛博摇卦'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _navigateToResultPage,
                  icon: Icon(Icons.play_arrow),
                  label: Text('开始排盘'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _viewHistory,
              icon: Icon(Icons.history),
              label: Text('查看历史记录'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}