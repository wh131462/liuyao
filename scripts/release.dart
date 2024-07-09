import 'dart:io';

import 'package:path/path.dart' as path;

void main() async {
  // 获取脚本所在目录的路径
  final rootPath = Directory.current.path;
  // 定义构建配置和输出目录，相对于脚本所在目录
  const buildPath = 'release';
  final outputDirectory = '$rootPath/$buildPath';

  // 确保输出目录存在
  Directory(outputDirectory).createSync(recursive: true);
  print("Current workspace: $rootPath");
  // 构建 APK 命令，注意这里使用相对路径
  var result = await Process.run(
      'flutter',
      ['build', 'apk', '--release', '--target-platform=android-arm64'],
      workingDirectory: rootPath,
      runInShell: true);

  // 检查命令是否执行成功
  if (result.exitCode != 0) {
    print('Error: Flutter build failed');
    print(result.stdout);
    print(result.stderr);
    exit(1);
  }
  // 移动为止
  var apkPath = path.join(
      rootPath, 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');
  var targetPath = path.join(outputDirectory, 'liuyao_1.0.0.apk');
  await File(apkPath).rename(targetPath);
  // 打印成功信息
  print('APK has been built successfully at: $targetPath');
}
