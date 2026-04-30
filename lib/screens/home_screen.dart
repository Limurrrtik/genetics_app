import 'package:flutter/material.dart';
import '../models/organism.dart';
import '../models/allele.dart';
import '../services/genetics_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Organism parent1 = const Organism(Allele.dominant, Allele.recessive);
  Organism parent2 = const Organism(Allele.dominant, Allele.recessive);
  Map<String, int> offspring = {};

  void _runCross() {
    setState(() {
      offspring = GeneticsEngine.cross(parent1, parent2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧬 Генетика для начинающих'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Симулятор скрещивания',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Родитель 1
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('👨‍👩‍👧‍ Родитель 1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Генотип: ${parent1.genotype}', style: const TextStyle(fontSize: 18)),
                    Text('Фенотип: ${parent1.phenotype}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Родитель 2
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('👨‍👩‍👧‍ Родитель 2', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Генотип: ${parent2.genotype}', style: const TextStyle(fontSize: 18)),
                    Text('Фенотип: ${parent2.phenotype}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Кнопка скрещивания
            ElevatedButton(
              onPressed: _runCross,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '🧬 Скрестить организмы',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            
            // Результаты
            if (offspring.isNotEmpty)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 Результаты скрещивания:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...offspring.entries.map((entry) {
                          final percentage = (entry.value / 4 * 100).toInt();
                          final phenotype = GeneticsEngine.getPhenotype(entry.key);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '• Генотип ${entry.key}: ${entry.value}/4 (${percentage}%) — $phenotype',
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}