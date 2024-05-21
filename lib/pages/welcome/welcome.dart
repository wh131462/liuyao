import 'dart:developer';

import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
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
                  showDialog(context: context, builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('古文解释'),
                      content: const Text("ddd"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('关闭'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
                  );
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
