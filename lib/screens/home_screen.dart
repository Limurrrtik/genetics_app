import 'history_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/organism.dart';
import '../models/allele.dart';
import '../models/trait_config.dart';
import '../models/cross_result.dart'; 
import '../services/genetics_engine.dart';
import '../services/history_service.dart';
import 'theory_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDihybrid = false;
  TraitConfig trait1 = TraitConfig.availableTraits[0];
  TraitConfig trait2 = TraitConfig.availableTraits.length > 1 
      ? TraitConfig.availableTraits[1] : TraitConfig.availableTraits[0];
  
  String p1t1 = 'Aa', p1t2 = 'Bb';
  String p2t1 = 'Aa', p2t2 = 'Bb';
  
  Map<String, int> results = {};
  List<String> punnettGrid = [];
  bool hasResults = false;

  void _runCross() {
    setState(() {
      if (isDihybrid) {
        results = GeneticsEngine.crossDi(p1t1, p1t2, p2t1, p2t2);
        List<String> getGametes(String t1, String t2) => [
          '${t1[0]}${t2[0]}', '${t1[0]}${t2[1]}', '${t1[1]}${t2[0]}', '${t1[1]}${t2[1]}'
        ];
        final g1 = getGametes(p1t1, p1t2);
        final g2 = getGametes(p2t1, p2t2);
        punnettGrid = [];
        for (final a in g1) {
          for (final b in g2) {
            String fmt(String x, String y) {
              final s = [x, y]..sort();
              return s.join();
            }
            punnettGrid.add('${fmt(a[0], b[0])}${fmt(a[1], b[1])}');
          }
        }
      } else {
        final org1 = Organism(
          p1t1[0] == 'A' ? Allele.dominant : Allele.recessive,
          p1t1[1] == 'A' ? Allele.dominant : Allele.recessive,
        );
        final org2 = Organism(
          p2t1[0] == 'A' ? Allele.dominant : Allele.recessive,
          p2t1[1] == 'A' ? Allele.dominant : Allele.recessive,
        );
        results = GeneticsEngine.crossMono(org1, org2);
        final g1 = [org1.allele1, org1.allele2];
        final g2 = [org2.allele1, org2.allele2];
        punnettGrid = [];
        for (final a in g1) for (final b in g2) {
          punnettGrid.add(Organism(a, b).genotype);
        }
      }
      hasResults = true;

      // 💾 Сохраняем в историю
      HistoryService.add(CrossResult(
        timestamp: DateTime.now(),
        isDihybrid: isDihybrid,
        trait1: trait1,
        trait2: isDihybrid ? trait2 : null,
        parent1T1: p1t1,
        parent1T2: p1t2,
        parent2T1: p2t1,
        parent2T2: p2t2,
        offspring: results,
      ));
    });
  }

  // 🎲 Логика случайного эксперимента
  void _randomExperiment() {
    setState(() {
      final traits = TraitConfig.availableTraits;
      final random = DateTime.now().millisecond;
      trait1 = traits[random % traits.length];
      trait2 = traits[(random + 1) % traits.length];
      final genotypes = ['AA', 'Aa', 'aa'];
      final bGenotypes = ['BB', 'Bb', 'bb'];
      p1t1 = genotypes[random % 3];
      p1t2 = bGenotypes[(random + 2) % 3];
      p2t1 = genotypes[(random + 4) % 3];
      p2t2 = bGenotypes[(random + 6) % 3];
      hasResults = false;
    });
  }

  String _getPhenotype(String genotype) {
    if (isDihybrid) {
      return GeneticsEngine.getPhenotypeDi(
        genotype,
        trait1.dominantLabel, trait1.recessiveLabel,
        trait2.dominantLabel, trait2.recessiveLabel,
      );
    } else {
      final org = Organism(
        genotype[0] == 'A' ? Allele.dominant : Allele.recessive,
        genotype[1] == 'A' ? Allele.dominant : Allele.recessive,
      );
      return (org.allele1 == Allele.dominant || org.allele2 == Allele.dominant)
          ? trait1.dominantLabel : trait1.recessiveLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧬 Генетика для начинающих', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TheoryScreen()),
            ),
            child: const Text('📖 Теория',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            child: const Text('🕒 История',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text('Режим скрещивания:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ToggleButtons(
                        isSelected: [!isDihybrid, isDihybrid],
                        onPressed: (i) => setState(() {
                          isDihybrid = i == 1;
                          hasResults = false;
                        }),
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Моно')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Ди')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 🎲 Кнопка случайного эксперимента
              ElevatedButton.icon(
                onPressed: _randomExperiment,
                icon: const Icon(Icons.casino),
                label: const Text('Случайный эксперимент'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[300],
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              if (isDihybrid) ...[
                _buildDropdown('Признак 1 (A/a)', trait1, (v) => setState(() { trait1 = v; hasResults = false; })),
                const SizedBox(height: 8),
                _buildDropdown('Признак 2 (B/b)', trait2, (v) => setState(() { trait2 = v; hasResults = false; })),
                const SizedBox(height: 16),
              ],

              _buildParent('Родитель 1', p1t1, p1t2, (g1, g2) => setState(() { p1t1 = g1; p1t2 = g2; hasResults = false; })),
              const SizedBox(height: 12),
              _buildParent('Родитель 2', p2t1, p2t2, (g1, g2) => setState(() { p2t1 = g1; p2t2 = g2; hasResults = false; })),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _runCross,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: Text(
                  isDihybrid ? '🧬 Скрестить (2 признака)' : '🧬 Скрестить',
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              if (hasResults) ...[
                Text(
                  isDihybrid ? '🧩 Решётка Пеннета (4×4)' : '🧩 Решётка Пеннета (2×2)',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildGrid(),
                const SizedBox(height: 20),
                _buildChart(),
                const SizedBox(height: 16),
                _buildStats(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, TraitConfig value, ValueChanged<TraitConfig> onChange) {
    return Center(
      child: DropdownButton<TraitConfig>(
        value: value,
        style: const TextStyle(fontSize: 16),
        items: TraitConfig.availableTraits.map((v) => 
          DropdownMenuItem(value: v, child: Text(v.name))
        ).toList(),
        onChanged: (v) => v != null ? onChange(v) : null,
      ),
    );
  }

  Widget _buildParent(String title, String t1, String t2, void Function(String, String) onChange) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(child: _buildGeno(t1, 'A', (v) => onChange(v, t2))),
            if (isDihybrid) ...[
              const SizedBox(height: 8),
              Center(child: _buildGeno(t2, 'B', (v) => onChange(t1, v))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGeno(String value, String letter, ValueChanged<String> onChange) {
    final opts = letter == 'B' ? ['BB', 'Bb', 'bb'] : ['AA', 'Aa', 'aa'];
    return DropdownButton<String>(
      value: value,
      style: const TextStyle(fontSize: 16),
      items: opts.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) => v != null ? onChange(v) : null,
    );
  }

  Widget _buildGrid() {
    final size = isDihybrid ? 4 : 2;
    final cellSize = isDihybrid ? 55.0 : 65.0; 
    final fontSize = isDihybrid ? 12.0 : 15.0; 
    
    List<String> getHeaders(String t1, String t2) {
      if (isDihybrid) {
        return ['${t1[0]}${t2[0]}', '${t1[0]}${t2[1]}', '${t1[1]}${t2[0]}', '${t1[1]}${t2[1]}'];
      }
      return [t1[0].toString(), t1[1].toString()];
    }

    Widget cell(String text, {bool header = false, bool result = false}) {
      return Container(
        width: cellSize,
        height: cellSize,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: header ? Colors.grey[300] : (result ? Colors.green[100] : Colors.white),
          border: Border.all(color: header ? Colors.grey : Colors.green[700]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: cellSize, height: cellSize),
            ...getHeaders(p1t1, p1t2).map((h) => cell(h, header: true)),
          ]),
          for (int i = 0; i < size; i++)
            Row(mainAxisSize: MainAxisSize.min, children: [
              cell(getHeaders(p2t1, p2t2)[i], header: true),
              for (int j = 0; j < size; j++)
                cell(punnettGrid[i * size + j], result: true),
            ]),
        ],
      ),
    );
  }

  Widget _buildChart() {
  // Если генотипов много (>5), используем столбцы вместо круга
  final useBarChart = results.length > 5;

  return Card(
    color: Colors.purple[50],
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(' Генотипы', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          if (useBarChart)
            // 📊 Столбчатая диаграмма для сложных случаев
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,  // Выравниваем по центру
                  groupsSpace: 12,                       // Делаем столбцы ближе друг к другу (было стандартное 16, потом 8, 10)
                  maxY: results.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= results.length) return const Text('');
                          return Text(
                            results.keys.toList()[index],
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: results.entries.map((e) {
                    return BarChartGroupData(
                      x: results.keys.toList().indexOf(e.key),
                      barRods: [
                        BarChartRodData(
                          toY: e.value.toDouble(),
                          color: _colorFor(e.key),
                          width: 15,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            )
          else
            // 🥧 Круговая диаграмма для простых случаев
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: results.entries.map((e) {
                    final total = isDihybrid ? 16 : 4;
                    final pct = (e.value / total * 100).toInt();
                    return PieChartSectionData(
                      value: e.value.toDouble(),
                      title: '${e.key}\n$pct%',
                      color: _colorFor(e.key),
                      radius: 45,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 1,
                  centerSpaceRadius: 25,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildStats() {
    final total = isDihybrid ? 16 : 4;
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📈 Результаты:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...results.entries.map((e) {
              final pct = (e.value / total * 100).toInt();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Icon(Icons.circle, size: 10, color: _colorFor(e.key)),
                  const SizedBox(width: 8),
                  Text('Генотип ${e.key}: $pct% — ${_getPhenotype(e.key)}',
                      style: const TextStyle(fontSize: 15)),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _colorFor(String g) {
    if (isDihybrid) {
      if (g.contains('A') && g.contains('B')) return Colors.blue;
      if (g.contains('A')) return Colors.orange;
      if (g.contains('B')) return Colors.purple;
      return Colors.red;
    }
    return g == 'AA' ? Colors.blue : (g == 'Aa' ? Colors.orange : Colors.red);
  }
}