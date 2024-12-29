import 'package:flutter/material.dart';
import 'package:liuyao/pages/about/about_page.dart';
import 'package:liuyao/pages/arrange/arrange.dart';
import 'package:liuyao/pages/book/book_list_page.dart';
import 'package:liuyao/pages/calendar/calendar_page.dart';
import 'package:liuyao/pages/hexagrams/hexagrams_page.dart';
import 'package:liuyao/pages/history/history_page.dart';
import 'package:liuyao/pages/login/login.dart';
import 'package:liuyao/pages/my/my.dart';
import 'package:liuyao/pages/password/forgot_password.dart';
import 'package:liuyao/pages/register/register.dart';
import 'package:liuyao/pages/settings/settings_page.dart';
import 'package:liuyao/pages/settings/theme_settings_page.dart';
import 'package:liuyao/pages/spinning/spinning_page.dart';
import 'package:liuyao/pages/userinfo/userinfo.dart';
import 'package:liuyao/pages/welcome/welcome.dart';
import 'package:liuyao/pages/xiaoliuren/xiaoliuren_page.dart';

class AppRoute {
  // 路由名称常量
  static const String welcome = '/';
  static const String hexagrams = '/hexagrams';
  static const String calendar = '/calendar';
  static const String arrange = '/arrange';
  static const String books = '/books';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String register = '/register';
  static const String my = '/my';
  static const String userInfo = '/userinfo';
  static const String themeSetting = '/themeSetting';
  static const String about = '/about';
  static const String forget = '/forget';
  static const String xiaoliuren = '/xiaoliuren';
  static const String spinning = '/spinning';

  // 基础路由表
  static final Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomePage(),
    about: (context) => const AboutPage(),
    hexagrams: (context) => HexagramsPage(),
    calendar: (context) => CalendarPage(),
    arrange: (context) => const ArrangePage(),
    books: (context) => BookListPage(),
    history: (context) => const HistoryPage(),
    settings: (context) => const SettingsPage(),
    login: (context) => LoginPage(),
    register: (context) => const RegisterPage(),
    forget: (context) => const ForgotPasswordPage(),
    my: (context) => const MyPage(),
    themeSetting: (context) => const ThemeSettingsPage(),
    xiaoliuren: (context) =>  XiaoLiuRenPage(),
    spinning: (context) =>  SpinningPage(),
  };

  // 处理动态路由
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case userInfo:
        final args = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => UserInfoPage(userId: args),
        );
      default:
        return null;
    }
  }

  // 处理未知路由
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
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
  }

  // 页面切换动画
  static PageRouteBuilder customPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
