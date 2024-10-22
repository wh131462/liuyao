import 'package:flutter/material.dart';
import 'package:liuyao/pages/welcome/welcome.dart';
import 'package:provider/provider.dart';
import 'store/schemas.dart';
import 'store/store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 确保Flutter环境初始化完成
  StoreService storeService = await StoreService.initialize([UserInfo.schema, HistoryItem.schema]);
  runApp(MultiProvider(
    providers: [
      Provider<StoreService>(
        create: (_) => storeService,
        dispose: (_, storeService) => storeService.close(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '六爻排卦',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const WelcomePage());
  }
}
