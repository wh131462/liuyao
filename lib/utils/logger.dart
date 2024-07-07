import 'package:logger/logger.dart';

class LiuyaoLogger {
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final _loggerWithStack = Logger(printer: PrettyPrinter());

  /// 输出信息
  info(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 输出带有函数栈的日志 - 默认两条
  infoWithStack(dynamic message, int? count) {
    Logger(printer: PrettyPrinter(methodCount: count ?? 2)).i(message);
  }

  /// 输出警告
  warn(dynamic message,
      {DateTime? time, Object? error, StackTrace? stackTrace}) {
    _logger.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// 输出错误日志
  error(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _loggerWithStack.e(message,
        time: time, error: error, stackTrace: stackTrace);
  }
  /// debug信息
  debug(dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }){
    _logger.d(message, time: time, error: error, stackTrace: stackTrace);
  }
  /// 普通追踪信息
  trace( dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }){
    _logger.t(message, time: time, error: error, stackTrace: stackTrace);
  }
}

/// 导出的日志实例
LiuyaoLogger logger = LiuyaoLogger();
