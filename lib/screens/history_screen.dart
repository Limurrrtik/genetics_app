import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/cross_result.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = HistoryService.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🕒 История скрещиваний'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Очистить историю',
            onPressed: () {
              HistoryService.clear();
              // Обновляем экран
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'История пуста',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Сделайте первое скрещивание!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryCard(item, index);
              },
            ),
    );
  }

  Widget _buildHistoryCard(CrossResult item, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с номером и временем
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Скрещивание #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _formatTime(item.timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Признаки
            Text('🧬 ${item.trait1.name}', style: const TextStyle(fontSize: 14)),
            if (item.isDihybrid)
              Text('🧬 ${item.trait2!.name}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            
            // Родители
            Text(
              '👨‍‍👧 Родитель 1: ${item.isDihybrid ? "${item.parent1T1}/${item.parent1T2}" : item.parent1T1}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              '👨‍👩‍👧 Родитель 2: ${item.isDihybrid ? "${item.parent2T1}/${item.parent2T2}" : item.parent2T1}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            
            // Результаты
            const Text('📊 Результаты:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...item.offspring.entries.map((e) {
              final total = item.isDihybrid ? 16 : 4;
              final pct = (e.value / total * 100).toInt();
              return Text(
                '• ${e.key}: $pct%',
                style: const TextStyle(fontSize: 12),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}