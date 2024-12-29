import 'package:flutter/material.dart';
import 'package:liuyao/components/page_scaffold.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/utils/liuyao.util.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'arrange.detail.dart';
import '../../models/history_item.dart';
import '../../store/store.dart';

class ArrangePage extends StatefulWidget {
  const ArrangePage({Key? key}) : super(key: key);

  @override
  State<ArrangePage> createState() => _ArrangePageState();
}

class _ArrangePageState extends State<ArrangePage> {
  final _questionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  DateTime _selectedDateTime = DateTime.now();
  bool _isManualMode = false; // 是否手动起卦

  // 存储六个爻位的值
  final List<int> _yaoValues = List.filled(6, 0); // 0:少阴, 1:少阳, 2:老阴, 3:老阳

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  // 选择日期时间
  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // 构建爻位选择器
  Widget _buildYaoSelector(int index) {
    return Row(
      children: [
        Text('第${index + 1}爻：'),
        DropdownButton<int>(
          value: _yaoValues[index],
          items: [
            DropdownMenuItem(value: 0, child: Text('少阴 ⚋')),
            DropdownMenuItem(value: 1, child: Text('少阳 ⚊')),
            DropdownMenuItem(value: 2, child: Text('老阴 ⚋')),
            DropdownMenuItem(value: 3, child: Text('老阳 ⚊')),
          ],
          onChanged: (value) {
            setState(() {
              _yaoValues[index] = value!;
            });
          },
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final question = _questionController.text;
      final answer =
          _isManualMode ? _generateManualAnswer() : _generateAutoAnswer();

      // 创建新的历史记录
      final historyItem = HistoryItem(
        id: const Uuid().v4(),
        question: question,
        originAnswer: answer,
        timestamp: _selectedDateTime.millisecondsSinceEpoch,
      );

      // 保存到数据库
      final storeService = context.read<StoreService>();
      try {
        await storeService.insertHistory(historyItem);
      } catch (e) {
        print('Database error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存失败: $e')),
          );
          return;
        }
      }

      if (mounted) {
        // 保存成功后跳转到详情页
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArrangeDetailPage(
              question: question,
              answer: answer,
              dateTime: _selectedDateTime,
              yaoValues: _yaoValues,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('起卦失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateManualAnswer() {
    // 将手动选择的爻值转换为六爻数字
    List<int> numList = _yaoValues.map((value) {
      switch (value) {
        case 0:
          return 8; // 少阴
        case 1:
          return 7; // 少阳
        case 2:
          return 6; // 老阴
        case 3:
          return 9; // 老阳
        default:
          return 8;
      }
    }).toList();

    // 使用 LiuYaoUtil 生成卦象
    final hexagrams = LiuYaoUtil.getHexagramsByText(numList.join());
    return hexagrams[Hexagram.original]?.getGuaProps().name ?? "未知卦象";
  }

  String _generateAutoAnswer() {
    // 使用 LiuYaoUtil 的随机生成方法
    List<int> numList = LiuYaoUtil.generateLiuYao();
    final hexagrams = LiuYaoUtil.getHexagramsByText(numList.join());
    return hexagrams[Hexagram.original]?.getGuaProps().name ?? "未知卦象";
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '六爻排盘',
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => Navigator.pushNamed(context, '/history'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 问题输入
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: '请输入求测事项',
                  border: OutlineInputBorder(),
                  helperText: '请详细描述您想要测算的问题',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入问题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 时间选择
              ListTile(
                title: Text(
                    '起卦时间：${_selectedDateTime.toString().substring(0, 16)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
              ),
              const Divider(),

              // 起卦方式选择
              SwitchListTile(
                title: const Text('手动起卦'),
                subtitle: Text(_isManualMode ? '手动选择爻位' : '自动随机起卦'),
                value: _isManualMode,
                onChanged: (value) => setState(() => _isManualMode = value),
              ),
              const Divider(),

              // 手动起卦时显示爻位选择器
              if (_isManualMode) ...[
                const Text('请选择每个爻位的值：', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                ...List.generate(6, (index) => _buildYaoSelector(index)),
                const SizedBox(height: 16),
              ],

              // 提交按钮
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('开始排盘',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
