import 'package:flutter/material.dart';
import 'package:liuyao/navigation/route.dart';
import 'package:provider/provider.dart';
import 'package:liuyao/core/file/file_manager.dart';
import 'package:liuyao/providers/theme_provider.dart';
import 'package:liuyao/providers/reader_provider.dart';
import 'package:liuyao/services/database_service.dart';
import 'package:liuyao/store/store.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化文件管理器
  await FileManager.initialize();
  
  final dbService = DatabaseService();
  final storeService = StoreService(dbService);
  await storeService.initializeLocal();

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: dbService),
        Provider<StoreService>.value(value: storeService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReaderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '六爻排卦',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: context.watch<ThemeProvider>().primaryColor,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: context.watch<ThemeProvider>().primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: context.watch<ThemeProvider>().themeMode,
      initialRoute: AppRoute.welcome,
      routes: AppRoute.routes,
      onGenerateRoute: AppRoute.onGenerateRoute,
      onUnknownRoute: AppRoute.onUnknownRoute,
    );
  }
}
