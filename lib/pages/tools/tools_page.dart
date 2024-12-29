import 'package:flutter/material.dart';
import 'package:liuyao/components/page_scaffold.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "工具箱",
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85, // 调整卡片宽高比
        children: [
          _buildToolCard(
            title: '小六壬',
            description: '快速占卜\n简单易用',
            icon: Icons.access_time_rounded,
            color: Colors.orange,
            onTap: () => Navigator.pushNamed(context, '/xiaoliuren'),
          ),
          _buildToolCard(
            title: '摇卦',
            description: '随机摇卦\n仅供娱乐',
            icon: Icons.casino_outlined,
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, '/spinning'),
          ),
          _buildToolCard(
            title: '书架',
            description: '易经相关\n书籍收藏',
            icon: Icons.menu_book_outlined,
            color: Colors.brown,
            onTap: () => Navigator.pushNamed(context, '/books'),
          ),
          _buildToolCard(
            title: '万年历',
            description: '农历阳历\n对照查询',
            icon: Icons.calendar_month_outlined,
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/calendar'),
          ),
          _buildToolCard(
            title: '六十四卦',
            description: '易经六十四卦\n详细解析',
            icon: Icons.grid_view_rounded,
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, '/hexagrams'),
          ),
        ],
      ),
    );
  }
} 