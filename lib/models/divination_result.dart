import 'package:lunar/lunar.dart';
import 'package:liuyao/constants/liuyao.const.dart';

class DivinationResult {
  final String question;
  final DateTime dateTime;
  final List<int> yaoValues;
  final Map<Hexagram, Xiang> hexagrams;
  final Solar solar;
  final Lunar lunar;
  
  // 节气信息
  final String solarTerm;
  // 空亡信息
  final String emptyGods;
  // 神煞信息
  final List<String> spirits;
  
  // 六亲关系类型
  static const Map<String, String> sixRelatives = {
    'brother': '兄弟',
    'child': '子孙',
    'mother': '父母',
    'wife': '妻财',
    'ghost': '鬼神',
    'official': '官鬼',
  };
  
  DivinationResult({
    required this.question,
    required this.dateTime,
    required this.yaoValues,
    required this.hexagrams,
  }) : 
    solar = Solar.fromDate(dateTime),
    lunar = Lunar.fromDate(dateTime),
    solarTerm = _getSolarTerm(dateTime),
    emptyGods = _getEmptyGods(dateTime),
    spirits = _getSpirits(dateTime);
    
  static String _getSolarTerm(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return lunar.getJieQi();
  }
  
  static String _getEmptyGods(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return '${lunar.getDayXunKong()}';
  }
  
  static List<String> _getSpirits(DateTime date) {
    final lunar = Lunar.fromDate(date);
    return [
      '日干支：${lunar.getDayInGanZhi()}',
      '日神：${lunar.getDayShengXiao()}',
      '值日天神：${_getDayGod(lunar)}',
      '日冲：${_getDayConflict(lunar)}',
      '日合：${_getDayHarmony(lunar)}',
      '日空：${lunar.getDayXunKong()}',
      '时辰：${lunar.getTimeZhi()}',
      '值时神：${_getTimeGod(lunar)}',
      '当前节气：${lunar.getJieQi()}',
      '下一节气：${lunar.getNextJieQi()}',
    ];
  }
  
  // 获取值日天神
  static String _getDayGod(Lunar lunar) {
    final dayZhi = lunar.getDayZhi();
    const godMap = {
      '子': '贵人',
      '丑': '天乙',
      '寅': '文昌',
      '卯': '金匮',
      '辰': '天德',
      '巳': '玉堂',
      '午': '司命',
      '未': '天刑',
      '申': '天巫',
      '酉': '天医',
      '戌': '天官',
      '亥': '天福',
    };
    return godMap[dayZhi] ?? '';
  }
  
  // 获取日冲
  static String _getDayConflict(Lunar lunar) {
    final dayZhi = lunar.getDayZhi();
    const conflictMap = {
      '子': '午',
      '丑': '未',
      '寅': '申',
      '卯': '酉',
      '辰': '戌',
      '巳': '亥',
      '午': '子',
      '未': '丑',
      '申': '寅',
      '酉': '卯',
      '戌': '辰',
      '亥': '巳',
    };
    return conflictMap[dayZhi] ?? '';
  }
  
  // 获取日合
  static String _getDayHarmony(Lunar lunar) {
    final dayZhi = lunar.getDayZhi();
    const harmonyMap = {
      '子': '丑',
      '寅': '亥',
      '卯': '戌',
      '辰': '酉',
      '巳': '申',
      '午': '未',
      '未': '午',
      '申': '巳',
      '酉': '辰',
      '戌': '卯',
      '亥': '寅',
      '丑': '子',
    };
    return harmonyMap[dayZhi] ?? '';
  }
  
  // 获取值时神
  static String _getTimeGod(Lunar lunar) {
    final timeZhi = lunar.getTimeZhi();
    const timeGodMap = {
      '子': '夜游',
      '丑': '天刑',
      '寅': '朱雀',
      '卯': '青龙',
      '辰': '勾陈',
      '巳': '螣蛇',
      '午': '太阳',
      '未': '六合',
      '申': '白虎',
      '酉': '太阴',
      '戌': '玄武',
      '亥': '天后',
    };
    return timeGodMap[timeZhi] ?? '';
  }
  
  // 获取六亲关系
  String getSixRelative(int yaoIndex) {
    final originalHexagram = hexagrams[Hexagram.original];
    if (originalHexagram == null) return '';

    // 获取本卦的卦主(用神)
    final mainGod = _getMainGod();
    // 获取指定爻的属性
    final yaoProperty = _getYaoProperty(yaoIndex);
    
    // 根据卦主和爻的属性判断六亲关系
    return _calculateSixRelative(mainGod, yaoProperty);
  }
  
  // 获取卦主(用神)
  String _getMainGod() {
    final lunar = Lunar.fromDate(dateTime);
    final dayGan = lunar.getDayGan(); // 获取日干
    
    // 根据日干确定卦主五行属性
    switch (dayGan) {
      case '甲':
      case '乙':
        return '木';
      case '丙':
      case '丁':
        return '火';
      case '戊':
      case '己':
        return '土';
      case '庚':
      case '辛':
        return '金';
      case '壬':
      case '癸':
        return '水';
      default:
        return '';
    }
  }
  
  // 获取爻的五行属性
  String _getYaoProperty(int yaoIndex) {
    final originalHexagram = hexagrams[Hexagram.original];
    if (originalHexagram == null) return '';

    // 根据爻的阴阳和所在位置判断五行属性
    final yaoValue = yaoValues[5 - yaoIndex];
    final isYang = yaoValue == 7 || yaoValue == 9;
    
    // 根据六爻位置和阴阳确定五行属性
    switch (yaoIndex) {
      case 0: // 初爻
        return isYang ? '水' : '土';
      case 1: // 二爻
        return isYang ? '土' : '木';
      case 2: // 三爻
        return isYang ? '木' : '火';
      case 3: // 四爻
        return isYang ? '火' : '金';
      case 4: // 五爻
        return isYang ? '金' : '水';
      case 5: // 上爻
        return isYang ? '水' : '土';
      default:
        return '';
    }
  }
  
  // 计算六亲关系
  String _calculateSixRelative(String mainGod, String yaoProperty) {
    // 根据五行生克关系判断六亲
    if (_isGenerating(mainGod, yaoProperty)) {
      return sixRelatives['mother']!; // 父母
    } else if (_isGenerating(yaoProperty, mainGod)) {
      return sixRelatives['child']!; // 子孙
    } else if (_isControlling(mainGod, yaoProperty)) {
      return sixRelatives['wife']!; // 妻财
    } else if (_isControlling(yaoProperty, mainGod)) {
      return sixRelatives['official']!; // 官鬼
    } else if (mainGod == yaoProperty) {
      return sixRelatives['brother']!; // 兄弟
    }
    return sixRelatives['ghost']!; // 鬼神
  }
  
  // 判断五行生关系
  bool _isGenerating(String source, String target) {
    const generateMap = {
      '木': '火',
      '火': '土',
      '土': '金',
      '金': '水',
      '水': '木',
    };
    return generateMap[source] == target;
  }
  
  // 判断五行克关系
  bool _isControlling(String source, String target) {
    const controlMap = {
      '木': '土',
      '土': '水',
      '水': '火',
      '火': '金',
      '金': '木',
    };
    return controlMap[source] == target;
  }
  
  // 获取世应位置
  Map<String, int> getWorldResponse() {
    final originalHexagram = hexagrams[Hexagram.original];
    if (originalHexagram == null) {
      return {'world': 0, 'response': 0};
    }

    // 获取卦的阴阳属性和月份
    final isYangGua = _isYangGua(originalHexagram);
    final month = lunar.getMonth();
    
    // 计算世爻位置
    final worldPosition = _calculateWorldPosition(month, isYangGua);
    // 应爻在世爻对面
    final responsePosition = (worldPosition + 3) % 6;

    return {
      'world': worldPosition + 1,
      'response': responsePosition + 1,
    };
  }
  
  // 判断是否阳卦
  bool _isYangGua(Xiang hexagram) {
    int yangCount = yaoValues.where((v) => v == 7 || v == 9).length;
    return yangCount > 3;
  }
  
  // 计算世爻位置
  int _calculateWorldPosition(int month, bool isYangGua) {
    // 根据四正卦和四维卦确定世爻位置
    if (isYangGua) {
      if (month >= 1 && month <= 3) return 2;  // 春季二世
      if (month >= 4 && month <= 6) return 4;  // 夏季四世
      if (month >= 7 && month <= 9) return 0;  // 秋季初世
      return 5;  // 冬季上世
    } else {
      if (month >= 1 && month <= 3) return 1;  // 春季三世
      if (month >= 4 && month <= 6) return 3;  // 夏季五世
      if (month >= 7 && month <= 9) return 5;  // 秋季上世
      return 0;  // 冬季初世
    }
  }

  // 获取动爻列表
  List<int> getMovingYaos() {
    List<int> movingYaos = [];
    for (int i = 0; i < yaoValues.length; i++) {
      if (yaoValues[i] == 6 || yaoValues[i] == 9) {
        movingYaos.add(i + 1);
      }
    }
    return movingYaos;
  }

  // 获取卦的五行属性
  String getHexagramElement() {
    final originalHexagram = hexagrams[Hexagram.original];
    if (originalHexagram == null) return '';

    // 根据卦象确定五行属性
    final props = originalHexagram.getGuaProps();
    return props.element ?? '未知';
  }

  // 判断是否伏吟
  bool isFuYin() {
    final original = hexagrams[Hexagram.original];
    final transformed = hexagrams[Hexagram.transformed];
    return original == transformed;
  }

  // 判断是否反吟
  bool isFanYin() {
    final original = hexagrams[Hexagram.original];
    final reversed = hexagrams[Hexagram.reversed];
    return original == reversed;
  }

  // 获取卦象解释
  Map<String, String> getHexagramInterpretation() {
    final original = hexagrams[Hexagram.original];
    if (original == null) return {};

    final props = original.getGuaProps();
    return {
      'name': props.name,
      'description': props.description,
      'judgment': props.judgment ?? '',
      'image': props.image ?? '',
      'element': props.element ?? '',
      'nature': props.nature ?? '',
      'attribute': props.attribute ?? '',
    };
  }

  // 获取爻辞
  String getYaoText(int position) {
    final original = hexagrams[Hexagram.original];
    if (original == null) return '';

    final props = original.getGuaProps();
    final yaoTexts = props.yaoTexts;
    if (yaoTexts == null || position < 0 || position >= yaoTexts.length) {
      return '';
    }
    return yaoTexts[position];
  }

  // 获取变卦解释
  Map<String, String> getTransformedInterpretation() {
    final transformed = hexagrams[Hexagram.transformed];
    if (transformed == null) return {};

    final props = transformed.getGuaProps();
    return {
      'name': props.name,
      'description': props.description,
      'judgment': props.judgment ?? '',
      'image': props.image ?? '',
    };
  }

  // 判断吉凶
  String getLuck() {
    final original = hexagrams[Hexagram.original];
    if (original == null) return '未知';

    final props = original.getGuaProps();
    return props.luck ?? '未知';
  }
} 