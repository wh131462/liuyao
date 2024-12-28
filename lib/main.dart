import 'package:flutter/material.dart';
import 'package:liuyao/pages/book/book_list_page.dart';
import 'package:liuyao/pages/spinning/spinning_page.dart';
import 'package:liuyao/pages/welcome/welcome.dart';
import 'package:liuyao/pages/xiaoliuren/xiaoliuren_page.dart';
import 'package:provider/provider.dart';
import 'package:liuyao/core/config/app_config.dart';
import 'package:liuyao/core/file/file_manager.dart';
import 'package:liuyao/providers/user_profile_provider.dart';
import 'package:liuyao/providers/theme_provider.dart';
import 'package:liuyao/providers/reader_provider.dart';
import 'dart:io';
import 'package:liuyao/services/database_service.dart';
import 'package:liuyao/store/store.dart';
import 'package:liuyao/pages/history/history_page.dart';
import 'package:liuyao/pages/settings/settings_page.dart';
import 'package:liuyao/pages/about/about_page.dart';
import 'pages/login/login.dart';
import 'pages/register/register.dart';
import 'pages/my/my.dart';
import 'pages/about/about_page.dart';
import 'pages/settings/theme_settings_page.dart';
import 'pages/settings/reader_settings_page.dart';
import 'pages/arrange/arrange.dart';
import 'pages/arrange/arrange.history.dart';
import 'pages/userinfo/userinfo.dart';
import 'pages/password/forgot_password.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/history': (context) => const HistoryPage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/my': (context) => const MyPage(),
        '/reader_settings': (context) => const ReaderSettingsPage(),
        '/arrange': (context) => const ArrangePage(),
        '/arrange_history': (context) => ArrangeHistory(),
        '/xiaoliuren': (context) => XiaoLiuRenPage(),
        '/spinning': (context) => SpinningPage(),
        '/book': (context) => BookListPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('页面未找到'),
            ),
            body: const Center(
              child: Text('抱歉，请求的页面不存在'),
            ),
          ),
        );
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/userinfo') {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => UserInfoPage(userId: args),
          );
        }
        return null;
      },
    );
  }
}
