import 'package:flutter/material.dart';

class TheoryScreen extends StatelessWidget {
  const TheoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Учебный раздел'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '👨‍🔬 Грегор Мендель',
              content: 'Австрийский монах и биолог, основоположник генетики. В 1865 году он опубликовал результаты своих опытов по скрещиванию гороха, сформулировав фундаментальные законы наследования признаков.',
              icon: Icons.science,
            ),
            _buildSection(
              title: '📖 Основные термины',
              content: '🧬 Ген — участок ДНК, отвечающий за признак.\n🔤 Аллель — вариант гена (например, A или a).\n📝 Генотип — набор аллелей организма (AA, Aa, aa).\n👀 Фенотип — внешнее проявление признака (цвет, форма).\n⬆️ Доминантный — признак, который проявляется всегда (A).\n⬇️ Рецессивный — признак, проявляющийся только при отсутствии доминантного (aa).',
              icon: Icons.book,
            ),
            _buildSection(
              title: ' Как работает решётка Пеннета?',
              content: 'Это таблица, которая показывает все возможные комбинации аллелей родителей. По горизонтали пишутся аллели одного родителя, по вертикали — другого. В клетках на пересечении записываются генотипы потомков.',
              icon: Icons.grid_on,
            ),
            _buildSection(
              title: '💡 Первый закон Менделя',
              content: 'Закон единообразия гибридов первого поколения: при скрещивании двух гомозиготных организмов (AA × aa) всё потомство будет одинаковым и гетерозиготным (Aa).',
              icon: Icons.lightbulb,
            ),
            _buildSection(
              title: '🔁 Второй закон Менделя',
              content: 'Закон расщепления: при скрещивании двух гетерозиготных организмов (Aa × Aa) в потомстве наблюдается расщепление по генотипу 1:2:1 и по фенотипу 3:1.',
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, required IconData icon}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}