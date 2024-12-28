import 'dart:io';

Future<void> runCommand(String executable, List<String> arguments, {String? workingDirectory}) async {
  final result = await Process.run(
    executable, 
    arguments,
    workingDirectory: workingDirectory,
  );
  print(result.stdout);
  if (result.stderr.toString().isNotEmpty) {
    print('错误: ${result.stderr}');
  }
  if (result.exitCode != 0) {
    throw '命令执行失败: $executable ${arguments.join(' ')}';
  }
}

void main() async {
  try {
    print('开始重建项目...');

    // 清理项目
    print('\n1. 清理项目...');
    await runCommand('flutter', ['clean']);
    
    // 清理 pub 缓存
    print('\n2. 清理 pub 缓存...');
    await runCommand('flutter', ['pub', 'cache', 'clean']);
    
    // 删除构建文件和缓存
    print('\n3. 清理构建文件和缓存...');
    final filesToDelete = [
      'ios/Pods',
      'ios/Podfile.lock',
      'ios/.symlinks',
      'ios/Flutter/Flutter.podspec',
      'ios/Flutter/flutter_export_environment.sh',
      'ios/Flutter/Generated.xcconfig',
      'ios/Flutter/flutter_assets',
      'ios/Flutter/App.framework',
      'ios/Flutter/Flutter.framework',
      'ios/Runner.xcworkspace',
      '.dart_tool',
      'build',
      'pubspec.lock',
      '.flutter-plugins',
      '.flutter-plugins-dependencies',
      '.packages',
    ];
    
    for (final file in filesToDelete) {
      if (await Directory(file).exists()) {
        await Directory(file).delete(recursive: true);
        print('删除目录: $file');
      } else if (await File(file).exists()) {
        await File(file).delete();
        print('删除文件: $file');
      }
    }

    // 获取依赖
    print('\n4. 获取 Flutter 依赖...');
    await runCommand('flutter', ['pub', 'get']);

    // 重新创建 iOS 项目
    print('\n5. 重新创建 iOS 项目...');
    await runCommand('flutter', ['create', '.', '--platforms=ios']);

    // 重新安装 Pods
    print('\n6. 重新安装 Pods...');
    await runCommand('pod', ['install'], workingDirectory: 'ios');

    // 重新构建项目
    print('\n7. 重新构建项目...');
    await runCommand('flutter', ['build', 'ios', '--no-codesign']);

    print('\n✅ 项目重建完成！');
    print('\n现在可以运行 flutter run 启动项目了。');
    
  } catch (e) {
    print('\n❌ 错误: $e');
    exit(1);
  }
}
