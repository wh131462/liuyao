import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/constants/xiang.dictionary.dart';
import 'package:liuyao/utils/logger.dart';

import 'hexagram.detail.dart';

class HexagramsPage extends StatefulWidget {
  @override
  _HexagramsPageState createState() => _HexagramsPageState();
}

class _HexagramsPageState extends State<HexagramsPage> {
  final List<Xiang> _allHexagrams = Xiang.values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('六十四卦'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: HexagramSearchDelegate(_allHexagrams),
              );
            },
          ),
        ],
      ),
      body: HexagramGrid(hexagrams: _allHexagrams),
    );
  }
}

class HexagramGrid extends StatelessWidget {
  final List<Xiang> hexagrams;

  HexagramGrid({required this.hexagrams});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: hexagrams.length,
      itemBuilder: (context, index) {
        return HexagramCard(hexagram: hexagrams[index]);
      },
    );
  }
}

class HexagramCard extends StatelessWidget {
  final Xiang hexagram;

  HexagramCard({required this.hexagram});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HexagramDetailPage(hexagram: hexagram),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
                text: TextSpan(
                    text: hexagram.getSymbolText(),
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 0.9))),
            Text(hexagram.name),
            Text("(${hexagram.getGuaProps().fullName})"),
          ],
        ),
      ),
    );
  }
}

class HexagramSearchDelegate extends SearchDelegate {
  final List<Xiang> allHexagrams;
  final List<Gua> searchGuaList = [];

  HexagramSearchDelegate(this.allHexagrams);

  @override
  String? get searchFieldLabel => "搜索卦象";

  @override
  void showSuggestions(BuildContext context) {
    if (searchGuaList.isNotEmpty) {
      var cur = "";
      for(var i = 0; i<searchGuaList.length;i++){
        cur += "${i==0?"上":"下"}${searchGuaList[i].name}";
      }
      query = cur;
    }
    super.showSuggestions(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          searchGuaList.clear();
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // 搜索框的文本样式
  @override
  TextStyle? get searchFieldStyle => TextStyle(fontSize: 18);

  @override
  Widget buildResults(BuildContext context) {
    final results = Xiang.values.where((hexagram) {
      if(searchGuaList.isNotEmpty){
        var cur = searchGuaList.join();
        return hexagram.guaList.join().contains(cur);
      }else{
        final isName = hexagram.name.contains(query);
        final props = hexagram.getGuaProps();
        final isFull = props.getFullText().contains(query);
        return isName || isFull;
      }
    }).toList();
    return HexagramGrid(hexagrams: results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return GuaSelectGrid(onGuaSelected: (Gua gua){
      if(searchGuaList.length>=2){
          searchGuaList.clear();
      }
      searchGuaList.add(gua);
      showSuggestions(context);
    });
  }
}

class GuaSelectGrid extends StatelessWidget {
  final guaList = Gua.values;
  final ValueChanged<Gua> onGuaSelected;

  GuaSelectGrid({required this.onGuaSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
        ),
        itemCount: guaList.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.0),
            ),
            onPressed: () {
              // 按钮点击事件处理逻辑
              logger.info('Selected: ${guaList[index].symbol}');
              onGuaSelected(guaList[index]);
            },
            child: Text(
              "${guaList[index].symbol}\n${guaList[index].name}",
              style: TextStyle(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}