import 'dart:io';

import 'package:path/path.dart' as path;

import 'utils.dart';

void main() async {
  // 获取脚本所在目录的路径
  final rootPath = ScriptUtil.rootPath();
  // 定义构建配置和输出目录，相对于脚本所在目录
  const buildPath = 'release';
  final outputDirectory = '$rootPath/$buildPath';
  // 确保输出目录存在
  Directory(outputDirectory).createSync(recursive: true);
  print("Current workspace: $rootPath");
  ScriptUtil.runScript(
      "flutter build apk --release --target-platform=android-arm64", rootPath,
      () async {
    var apkPath = path.join(
        rootPath, 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');
    var targetPath = path.join(outputDirectory, 'liuyao_1.0.0.apk');
    await File(apkPath).rename(targetPath);
    // 打印成功信息
    print('APK has been built successfully at: file://$targetPath');
  }, () {
    print('Script run failed.');
    exit(1);
  });
}
