import 'utils.dart';

void main() async {
  // 获取脚本所在目录的路径
  final rootPath = ScriptUtil.rootPath();
  ScriptUtil.runScript(
      "flutter pub run flutter_launcher_icons:main", rootPath, null, null);
}
