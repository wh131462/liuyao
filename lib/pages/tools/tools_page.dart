import 'package:flutter/material.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildToolCard(
            context,
            '小六壬',
            'assets/images/head_pic1.jpg',
            '快速占卜，简单易用',
            () => Navigator.pushNamed(context, '/xiaoliuren'),
          ),
          _buildToolCard(
            context,
            '摇卦',
            'assets/images/head_pic1.jpg',
            '随机摇出卦象(仅供娱乐)',
            () => Navigator.pushNamed(context, '/spinning'),
          ),
          _buildToolCard(
            context,
            '书架',
            'assets/images/head_pic1.jpg',
            '阅读书籍',
            () => Navigator.pushNamed(context, '/book'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    String imagePath,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 64,
              height: 64,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 