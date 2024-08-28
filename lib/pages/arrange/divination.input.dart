import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DivinationInput extends StatelessWidget {
  final TextEditingController numberEditingController;

  DivinationInput({required this.numberEditingController});

  void _showDivinationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('六爻排卦信息'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('原则:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('不诚不占，不义不占，不疑不占。'),
                SizedBox(height: 10),
                Text('排卦方法', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('原料: 三枚硬币(一枚也可以)'),
                Text('方式: 心中默念自己想要得到答案的问题，在手中摇动硬币并掷出硬币落地，三枚一组，记下硬币的正反面排布（一枚硬币的话就是掷三次为一组查看）对应的数字[6789]，进行六次投掷后成卦。'),
                SizedBox(height: 10),
                Text('硬币排布对照表', style: TextStyle(fontWeight: FontWeight.bold)),
                Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('对应数字', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('含义', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('符号记法', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('硬币排布情况', style: TextStyle(fontWeight: FontWeight.bold))),
                    ]),
                    TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('6')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('老阴')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('--x或x')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('三字')),
                    ]),
                    TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('7')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('少阳')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('—或,,')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('两花一字')),
                    ]),
                    TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('8')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('少阴')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('--或,,,')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('两字一花')),
                    ]),
                    TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('9')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('老阳')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('—o或o')),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('三花')),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          maxLength: 6,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[6789]'))],
          controller: numberEditingController,
          decoration: InputDecoration(
            labelText: '答案在其中',
            labelStyle: TextStyle(fontSize: 18),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.only(bottom: 22),
          icon: Icon(Icons.help_outline),
          onPressed: () => _showDivinationInfo(context),
        ),
      ],
    );
  }
}