import 'package:flutter/material.dart';
import '../models/organism.dart';
import '../models/allele.dart';
import '../models/trait_config.dart';
import '../services/genetics_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String parent1Genotype = 'Aa';
  String parent2Genotype = 'Aa';
  
  // Выбранный признак (по умолчанию Горох)
  TraitConfig currentTrait = TraitConfig.availableTraits[0];

  Organism? parent1;
  Organism? parent2;
  Map<String, int> offspring = {};
  List<Organism> punnettResults = [];
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
      
      offspring = GeneticsEngine.cross(parent1!, parent2!);
      
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

  // Функция для определения текста признака
  String _getPhenotypeText(Organism org) {
    if (org.allele1 == Allele.dominant || org.allele2 == Allele.dominant) {
      return currentTrait.dominantLabel;
    }
    return currentTrait.recessiveLabel;
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
              //  ВЫБОР ПРИЗНАКА
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text('Выберите признак для изучения:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<TraitConfig>(
                        isExpanded: true,
                        value: currentTrait,
                        items: TraitConfig.availableTraits.map((TraitConfig value) {
                          return DropdownMenuItem<TraitConfig>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                        onChanged: (TraitConfig? newValue) {
                          setState(() {
                            currentTrait = newValue!;
                            hasResults = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
              
              // Родитель 2
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('👨‍👧‍ Родитель 2', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              
              if (hasResults) ...[
                const Text(
                  '🧩 Решётка Пеннета:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildPunnettCell(parent1!.allele1.symbol, isHeader: true),
                        _buildPunnettCell(parent1!.allele2.symbol, isHeader: true),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            _buildPunnettCell(parent2!.allele1.symbol, isHeader: true),
                            _buildPunnettResultCell(punnettResults[0]),
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
                
                // Статистика с НАЗВАНИЯМИ ПРИЗНАКОВ
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📈 Вероятности появления признака:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...offspring.entries.map((entry) {
                          final percentage = (entry.value / 4 * 100).toInt();
                          // Получаем текст признака из любого потомка этого генотипа
                          final phenotypeText = _getPhenotypeText(Organism(
                            entry.key[0] == 'A' ? Allele.dominant : Allele.recessive,
                            entry.key[1] == 'A' ? Allele.dominant : Allele.recessive,
                          ));
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 10, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Генотип ${entry.key}: ${percentage}% — $phenotypeText',
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