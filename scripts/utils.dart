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
    StreamController<String> streamController = StreamController();
    // 执行传入的命令
    print("[RUN]: $command");
    var process = await Process.start(
      command,
      [],
      runInShell: true,
      workingDirectory: workspaceDir,
    );
    // 将进程的标准输出连接到流控制器
    process.stdout.transform(utf8.decoder).listen((String output) {
      // 实时打印输出
      streamController.add(output);
    });
    process.stderr.transform(utf8.decoder).listen((String output) {
      // 实时打印输出
      streamController.add(output);
    });
    // 监听流，实时输出数据
    streamController.stream.listen((String output) {
      print(output);
    });
    process.exitCode.then((int code) {
      if (code == 0) {
        // 如果命令成功执行，调用成功回调函数
        if (success != null) {
          success();
        }
      } else {
        // 打印错误信息
        print('[RUN:error]: Script execution failed');
        // 调用失败回调函数
        if (fail != null) {
          fail();
        }
      }
    }, onError: (err) {
      // 捕获并打印异常信息
      print('[RUN:error]: Exception occurred: $err');
      // 调用失败回调函数
      if (fail != null) {
        fail();
      }
    });
  }
}
