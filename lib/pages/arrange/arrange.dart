// 导入必要的包
import 'package:flutter/material.dart';

// 创建一个新的路由页面
class ArrangePage extends StatelessWidget {
  const ArrangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排卦'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 返回到上一个页面
            Navigator.pop(context);
          },
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}