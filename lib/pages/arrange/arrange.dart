import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liuyao/constants/liuyao.const.dart';
import 'package:liuyao/pages/arrange/arrange.detail.dart';
import 'package:liuyao/utils/liuyao.util.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:liuyao/core/file/file_manager.dart';

import '../calendar/calendar.dart';
import 'arrange.history.dart';
import 'divination.input.dart';
import '../../models/history_item.dart';
import '../../services/database_service.dart';
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
  String? _selectedImagePath;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final question = _questionController.text;
      final answer = _generateAnswer(); // 生成卦象答案的方法
      
      // 创建新的历史记录
      final historyItem = HistoryItem(
        id: const Uuid().v4(),
        question: question,
        originAnswer: answer,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // 保存到数据库
      final storeService = context.read<StoreService>();
      await storeService.insertHistory(historyItem);

      // 清空输入
      _questionController.clear();

      // 导航到详情页
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArrangeDetailPage(
              question: question,
              answer: answer,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateAnswer() {
    // TODO: 实现六爻卦象生成逻辑
    // 这里应该实现实际的卦象生成算法
    return "乾为天";
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    
    if (file != null) {
      final savedFile = await FileManager.importFile(file.path, 'avatar');
      if (savedFile != null) {
        setState(() {
          _selectedImagePath = savedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('求问'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArrangeHistory()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: '请输入您的问题',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入问题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('开始求问'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}