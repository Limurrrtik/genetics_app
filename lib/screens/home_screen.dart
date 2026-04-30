import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/organism.dart';
import '../models/allele.dart';
import '../models/trait_config.dart';
import '../services/genetics_engine.dart';
import 'theory_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDihybrid = false;

  // Признаки
  TraitConfig trait1 = TraitConfig.availableTraits[0];
  TraitConfig trait2 = TraitConfig.availableTraits.length > 1 ? TraitConfig.availableTraits[1] : TraitConfig.availableTraits[0];

  // Генотипы родителей
  String p1t1 = 'Aa', p1t2 = 'Bb';
  String p2t1 = 'Aa', p2t2 = 'Bb';

  Map<String, int> results = {};
  List<String> punnettGrid = [];
  bool hasResults = false;

  void _runCross() {
    setState(() {
      if (isDihybrid) {
        results = GeneticsEngine.crossDi(p1t1, p1t2, p2t1, p2t2);
        // Формируем сетку 4x4 для отображения
        List<String> getGametes(String t1, String t2) => [
          '${t1[0]}${t2[0]}', '${t1[0]}${t2[1]}', '${t1[1]}${t2[0]}', '${t1[1]}${t2[1]}'
        ];
        final g1 = getGametes(p1t1, p1t2);
        final g2 = getGametes(p2t1, p2t2);
        punnettGrid = [];
        for (final a in g1) {
          for (final b in g2) {
            // Красивая сортировка аллелей в ячейке
            String fmt(String x, String y) {
              final s = [x, y]..sort();
              return s.join();
            }
            punnettGrid.add('${fmt(a[0], b[0])}${fmt(a[1], b[1])}');
          }
        }
      } else {
        final org1 = Organism(p1t1[0]=='A'?Allele.dominant:Allele.recessive, p1t1[1]=='A'?Allele.dominant:Allele.recessive);
        final org2 = Organism(p2t1[0]=='A'?Allele.dominant:Allele.recessive, p2t1[1]=='A'?Allele.dominant:Allele.recessive);
        results = GeneticsEngine.crossMono(org1, org2);
        final g1 = [org1.allele1, org1.allele2];
        final g2 = [org2.allele1, org2.allele2];
        punnettGrid = [];
        for (final a in g1) for (final b in g2) punnettGrid.add(Organism(a,b).genotype);
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
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TheoryScreen())),
            child: const Text('📖 Теория', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Переключатель режима
              Card(
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text('Режим скрещивания:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ToggleButtons(
                        isSelected: [!isDihybrid, isDihybrid],
                        onPressed: (i) => setState(() { isDihybrid = i == 1; hasResults = false; }),
                        borderRadius: BorderRadius.circular(8),
                        children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Моно (1 признак)')), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Ди (2 признака)'))],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Выбор признаков
              if (isDihybrid) ...[
                _buildTraitDropdown('Признак 1 (A/a)', trait1, (v) => setState(() { trait1 = v; hasResults = false; })),
                const SizedBox(height: 8),
                _buildTraitDropdown('Признак 2 (B/b)', trait2, (v) => setState(() { trait2 = v; hasResults = false; })),
                const SizedBox(height: 16),
              ],

              // Родители
              _buildParentCard('Родитель 1', p1t1, p1t2, (g1, g2) => setState(() { p1t1 = g1; p1t2 = g2; hasResults = false; })),
              const SizedBox(height: 12),
              _buildParentCard('Родитель 2', p2t1, p2t2, (g1, g2) => setState(() { p2t1 = g1; p2t2 = g2; hasResults = false; })),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _runCross,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('🧬 Скрестить', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 20),

              if (hasResults) ...[
                Text(
                  isDihybrid ? '🧩 Решётка Пеннета (4×4):' : '🧩 Решётка Пеннета (2×2):',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildPunnettGrid(),
                const SizedBox(height: 20),
                _buildPieChart(),
                const SizedBox(height: 16),
                _buildStatsList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraitDropdown(String label, TraitConfig value, ValueChanged<TraitConfig> onChanged) {
    return Card(child: Padding(padding: const EdgeInsets.all(8), child: DropdownButton<TraitConfig>(isExpanded: true, value: value, items: TraitConfig.availableTraits.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(), onChanged: (v) => onChanged(v!))));
  }

  Widget _buildParentCard(String title, String t1, String t2, void Function(String, String) onChanged) {
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _buildGenoDropdown(t1, (v) => onChanged(v, t2)),
      if (isDihybrid) ...[const SizedBox(height: 8), _buildGenoDropdown(t2, (v) => onChanged(t1, v))],
    ])));
  }

  Widget _buildGenoDropdown(String value, ValueChanged<String> onChanged) {
    return DropdownButton<String>(value: value, items: ['AA','Aa','aa'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => onChanged(v!));
  }

  Widget _buildPunnettGrid() {
    final size = isDihybrid ? 4 : 2;
    final headers = isDihybrid 
      ? [p1t1[0]+p1t2[0], p1t1[0]+p1t2[1], p1t1[1]+p1t2[0], p1t1[1]+p1t2[1]]
      : [p1t1[0].toString(), p1t1[1].toString()]; // Упрощено для моно
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: size + 1,
      childAspectRatio: 1,
      children: [
        // Верхний левый угол пустой
        const SizedBox(),
        // Заголовки сверху (гаметы родителя 1)
        ...headers.map((h) => Container(margin: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)), child: Center(child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold))))),
        // Строки с заголовками слева и результатами
        for (int i = 0; i < size; i++) ...[
          Container(margin: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)), child: Center(child: Text(isDihybrid ? [p2t1[0],p2t2[0],p2t1[0],p2t2[1],p2t1[1],p2t2[0],p2t1[1],p2t2[1]][i] : [p2t1[0],p2t1[1]][i], style: const TextStyle(fontWeight: FontWeight.bold)))),
          for (int j = 0; j < size; j++)
            Container(margin: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.green[100], border: Border.all(color: Colors.green[700]!), borderRadius: BorderRadius.circular(6)), child: Center(child: Text(punnettGrid[i * size + j], style: const TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ],
    );
  }

  Widget _buildPieChart() {
    final sections = results.entries.map((e) {
      final pct = (e.value / (isDihybrid ? 16 : 4) * 100).toInt();
      return PieChartSectionData(value: e.value.toDouble(), title: '${e.key}\n$pct%', color: _getColor(e.key), radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white));
    }).toList();
    return Card(color: Colors.purple[50], child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Text(' Распределение генотипов:', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 150, child: PieChart(PieChartData(sections: sections, sectionsSpace: 1, centerSpaceRadius: 30)))])));
  }

  Widget _buildStatsList() {
    return Card(color: Colors.green[50], child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('📈 Вероятности:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...results.entries.map((e) {
        final pct = (e.value / (isDihybrid ? 16 : 4) * 100).toInt();
        final pheno = isDihybrid 
          ? GeneticsEngine.getPhenotypeDi(e.key, trait1.dominantLabel, trait1.recessiveLabel, trait2.dominantLabel, trait2.recessiveLabel)
          : GeneticsEngine.getPhenotypeMono(e.key);
        return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Icon(Icons.circle, size: 10, color: _getColor(e.key)), const SizedBox(width: 8), Text('Генотип ${e.key}: $pct% — $pheno')]));
      }),
    ])));
  }

  Color _getColor(String g) {
    if (g.contains('A') && g.contains('B')) return Colors.blue;
    if (g.contains('A')) return Colors.orange;
    if (g.contains('B')) return Colors.purple;
    return Colors.red;
  }
}