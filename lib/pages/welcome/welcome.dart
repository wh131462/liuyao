export "./welcome.dart";
import 'package:flutter/material.dart';

import '../arrange/arrange.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '六爻排盘',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('选择工具'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const ArrangePage()));
                },
                child: const Text("排卦"),
              ),
              ElevatedButton(
                onPressed: () {

                },
                child: const Text("六十四卦"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
