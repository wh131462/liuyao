import 'package:flutter/material.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/pages/hexagrams/hexagram.detail.dart';
import 'package:liuyao/utils/liuyao.util.dart';

class ArrangeDetailPage extends StatefulWidget {
  final String question;
  final String answer;

  // 通过构造函数传递解析结果
  ArrangeDetailPage({super.key, required this.question, required this.answer});

  @override
  _ArrangeDetailPageState createState() => _ArrangeDetailPageState();
}

class _ArrangeDetailPageState extends State<ArrangeDetailPage> {
  Map<Hexagram, Xiang>? _hexagrams;
  bool _isLoading = true;
  String? _error;
  List<int>? _generatedNumbers;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _initializeHexagrams();
    }
  }

  Future<void> _initializeHexagrams() async {
    try {
      // 生成六个随机数（6、7、8、9）
      _generatedNumbers = LiuYaoUtil.generateLiuYao();
      
      // 根据生成的数字创建卦象
      final hexagrams = {
        Hexagram.original: LiuYaoUtil.getOriginalHexagramByNumber(_generatedNumbers!),
        Hexagram.transformed: LiuYaoUtil.getTransformedHexagramByNumber(_generatedNumbers!),
        Hexagram.mutual: LiuYaoUtil.getMutualHexagramByNumber(_generatedNumbers!),
        Hexagram.reversed: LiuYaoUtil.getReversedHexagramByNumber(_generatedNumbers!),
        Hexagram.opposite: LiuYaoUtil.getOppositeHexagramByNumber(_generatedNumbers!),
      };
      
      if (mounted) {
        setState(() {
          _hexagrams = hexagrams;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '生成卦象失败: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _hexagrams == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('错误'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? '未知错误'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _initializeHexagrams();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('排卦结果'),
        actions: [
          // 添加重新生成按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initializeHexagrams();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 显示问题
            Text(
              "求问: ${widget.question}",
              style: const TextStyle(
                fontSize: 32,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 显示生成的数字
            if (_generatedNumbers != null) ...[
              Text(
                "生成数字: ${_generatedNumbers!.join(', ')}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 显示各种卦象
            _buildHexagramSection("本卦", Hexagram.original),
            _buildHexagramSection("变卦", Hexagram.transformed),
            _buildHexagramSection("错卦", Hexagram.reversed),
            _buildHexagramSection("互卦", Hexagram.mutual),
            _buildHexagramSection("综卦", Hexagram.opposite),
          ],
        ),
      ),
    );
  }

  Widget _buildHexagramSection(String label, Hexagram type) {
    final hexagram = _hexagrams![type]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTextButton(context, label, hexagram),
        Text(
          type.description,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(hexagram.getGuaProps().originalHexagram),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 获取跳转文本按钮
  GestureDetector getTextButton(BuildContext context, String label, Xiang hexagram) {
    return GestureDetector(
      child: Text(
        '$label: ${hexagram.getGuaProps().name}',
        style: const TextStyle(
          fontSize: 32,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HexagramDetailPage(hexagram: hexagram),
          ),
        );
      },
    );
  }
}