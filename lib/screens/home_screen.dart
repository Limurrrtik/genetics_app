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
  String parent1Genotype = 'Aa';
  String parent2Genotype = 'Aa';
  
  Organism? parent1;
  Organism? parent2;
  Map<String, int> offspring = {};
  List<Organism> punnettResults = []; // Для решётки Пеннета
  bool hasResults = false;

  Organism _createOrganismFromGenotype(String genotype) {
    final allele1 = genotype[0] == 'A' ? Allele.dominant : Allele.recessive;
    final allele2 = genotype[1] == 'A' ? Allele.dominant : Allele.recessive;
    return Organism(allele1, allele2);
  }

  void _runCross() {
    setState(() {
      parent1 = _createOrganismFromGenotype(parent1Genotype);
      parent2 = _createOrganismFromGenotype(parent2Genotype);
      
      // Считаем статистику
      offspring = GeneticsEngine.cross(parent1!, parent2!);
      
      // Считаем для решётки Пеннета (по порядку)
      final g1 = [parent1!.allele1, parent1!.allele2];
      final g2 = [parent2!.allele1, parent2!.allele2];
      punnettResults = [];
      for (final a1 in g1) {
        for (final a2 in g2) {
          punnettResults.add(Organism(a1, a2));
        }
      }
      
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
              
              // Выбор Родителя 1
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('👨‍‍👧‍ Родитель 1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Выбор Родителя 2
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('👨‍‍👧‍ Родитель 2', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
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
              
              // РЕШЁТКА ПЕННЕТА
              if (hasResults) ...[
                const Text(
                  ' Решётка Пеннета:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Сама таблица
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Верхняя строка (аллели родителя 1)
                    Column(
                      children: [
                        const SizedBox(height: 40), // Отступ под заголовок
                        _buildPunnettCell(parent1!.allele1.symbol, isHeader: true),
                        _buildPunnettCell(parent1!.allele2.symbol, isHeader: true),
                      ],
                    ),
                    Column(
                      children: [
                        // Заголовки слева (аллели родителя 2) и ячейки
                        Row(
                          children: [
                            _buildPunnettCell(parent2!.allele1.symbol, isHeader: true),
                            _buildPunnettResultCell(punnettResults[0]), // AA или Aa
                            _buildPunnettResultCell(punnettResults[1]),
                          ],
                        ),
                        Row(
                          children: [
                            _buildPunnettCell(parent2!.allele2.symbol, isHeader: true),
                            _buildPunnettResultCell(punnettResults[2]),
                            _buildPunnettResultCell(punnettResults[3]),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Текстовая статистика
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📈 Вероятности:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...offspring.entries.map((entry) {
                          final percentage = (entry.value / 4 * 100).toInt();
                          final phenotype = GeneticsEngine.getPhenotype(entry.key);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 10, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Генотип ${entry.key}: ${percentage}% — $phenotype',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный виджет для ячеек таблицы
  Widget _buildPunnettCell(String text, {bool isHeader = false}) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey[300] : Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: isHeader ? Colors.black : Colors.green[800],
          ),
        ),
      ),
    );
  }

  // Виджет для ячейки с результатом
  Widget _buildPunnettResultCell(Organism org) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.green[100],
        border: Border.all(color: Colors.green[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          org.genotype,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}