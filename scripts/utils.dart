import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef void CallbackFunction();

class ScriptUtil {
  /// 根目录
  static String rootPath() {
    return Directory.current.path;
  }

  /// 执行脚本
  static void runScript(String command, String workspaceDir,
      CallbackFunction? success, CallbackFunction? fail) async {
    final streamController = StreamController<String>();
    try {
      // 确定要使用的shell命令
      String shell;
      List<String> arguments;
      if (Platform.isWindows) {
        shell = 'cmd';
        arguments = ['/c', command];
      } else {
        shell = 'bash';
        arguments = ['-c', command];
      }

      // 执行传入的命令
      print("[RUN]: $command");
      final process = await Process.start(
        shell,
        arguments,
        runInShell: true,
        workingDirectory: workspaceDir,
      );

      // 将进程的标准输出连接到流控制器
      process.stdout.transform(utf8.decoder).listen(streamController.add);
      process.stderr.transform(utf8.decoder).listen(streamController.add);

      // 监听流，实时输出数据
      streamController.stream.listen(print);

      // 等待进程退出
      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        // 如果命令成功执行，调用成功回调函数
        success?.call();
      } else {
        // 打印错误信息
        print('[RUN:error]: Script execution failed with exit code $exitCode');
        // 调用失败回调函数
        fail?.call();
      }
    } catch (err) {
      // 捕获并打印异常信息
      print('[RUN:error]: Exception occurred: $err');
      // 调用失败回调函数
      fail?.call();
    } finally {
      // 关闭流控制器
      await streamController.close();
    }
  }
}
