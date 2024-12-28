import 'dart:io';

void main() async {
  // 运行代码生成
  await Process.run('flutter', ['pub', 'run', 'realm', 'generate']);
  
  // 运行 flutter clean
  await Process.run('flutter', ['clean']);
  
  // 获取依赖
  await Process.run('flutter', ['pub', 'get']);
  
  // 分析项目并修复可能的问题
  await Process.run('flutter', ['analyze', '--fix']);
  
  print('项目清理和修复完成！');
} 