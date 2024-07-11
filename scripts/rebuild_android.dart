import 'dart:io';

import 'package:path/path.dart' as path;

import 'utils.dart';

void main() async {
  // 获取脚本所在目录的路径
  final rootPath = ScriptUtil.rootPath();
  final androidGradleW = path.join(rootPath, 'android');
  final gradlew = Platform.isWindows?'./gradlew.bat':'./gradlew';
  ScriptUtil.runScript('$gradlew clean', androidGradleW, null, null);
  ScriptUtil.runScript('$gradlew build', androidGradleW, null, null);
}
