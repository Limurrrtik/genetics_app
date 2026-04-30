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
  // Выбранные генотипы родителей
  String parent1Genotype = 'Aa';
  String parent2Genotype = 'Aa';
  
  Organism? parent1;
  Organism? parent2;
  Map<String, int> offspring = {};
  bool hasResults = false;

  // Создаём организм из строки генотипа
  Organism _createOrganismFromGenotype(String genotype) {
    final allele1 = genotype[0] == 'A' ? Allele.dominant : Allele.recessive;
    final allele2 = genotype[1] == 'A' ? Allele.dominant : Allele.recessive;
    return Organism(allele1, allele2);
  }

  void _runCross() {
    setState(() {
      parent1 = _createOrganismFromGenotype(parent1Genotype);
      parent2 = _createOrganismFromGenotype(parent2Genotype);
      offspring = GeneticsEngine.cross(parent1!, parent2!);
      hasResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧬 Генетика для начинающих'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              
              // Родитель 1 с выбором
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('👨‍👩‍👧‍ Родитель 1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: parent1Genotype,
                        items: <String>['AA', 'Aa', 'aa'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text('Генотип: $value', style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            parent1Genotype = newValue!;
                            hasResults = false;
                          });
                        },
                      ),
                      if (parent1 != null && parent1Genotype == _organismToGenotype(parent1!)) ...[
                        const SizedBox(height: 8),
                        Text('Фенотип: ${parent1!.phenotype}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Родитель 2 с выбором
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('👨‍‍👧 Родитель 2', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: parent2Genotype,
                        items: <String>['AA', 'Aa', 'aa'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text('Генотип: $value', style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            parent2Genotype = newValue!;
                            hasResults = false;
                          });
                        },
                      ),
                      if (parent2 != null && parent2Genotype == _organismToGenotype(parent2!)) ...[
                        const SizedBox(height: 8),
                        Text('Фенотип: ${parent2!.phenotype}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      ],
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
              if (hasResults && offspring.isNotEmpty)
                Card(
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
            ],
          ),
        ),
      ),
    );
  }

  String _organismToGenotype(Organism organism) {
    return organism.genotype;
  }
}