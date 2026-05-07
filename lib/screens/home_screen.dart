// ════════════════════════════════════════════════════════════════════════════
// 📦 ИМПОРТЫ БИБЛИОТЕК
// ════════════════════════════════════════════════════════════════════════════
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/organism.dart';
import '../models/allele.dart';
import '../models/trait_config.dart';
import '../models/cross_result.dart';
import '../services/genetics_engine.dart';
import '../services/history_service.dart';
import 'theory_screen.dart';
import 'history_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// 🏠 ГЛАВНЫЙ ЭКРАН ПРИЛОЖЕНИЯ
// ════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ──────────────────────────────────────────────────────────────────────────
  // 📊 ПЕРЕМЕННЫЕ СОСТОЯНИЯ (данные экрана)
  // ──────────────────────────────────────────────────────────────────────────
  bool isDihybrid = false; // false = моногибридное, true = дигибридное
  TraitConfig trait1 = TraitConfig.availableTraits[0]; // Первый признак
  TraitConfig trait2 = TraitConfig.availableTraits.length > 1 
      ? TraitConfig.availableTraits[1] : TraitConfig.availableTraits[0]; // Второй признак
  
  String p1t1 = 'Aa', p1t2 = 'Bb'; // Генотипы родителя 1
  String p2t1 = 'Aa', p2t2 = 'Bb'; // Генотипы родителя 2
  
  Map<String, int> results = {}; // Результаты скрещивания (генотип: количество)
  List<String> punnettGrid = []; // Решётка Пеннета (для отображения)
  bool hasResults = false; // Есть ли результаты для показа

  // ════════════════════════════════════════════════════════════════════════════
  // 🔬 ЛОГИКА СКРЕЩИВАНИЯ
  // ════════════════════════════════════════════════════════════════════════════
  
  // 🧬 Основная функция скрещивания
  void _runCross() {
    setState(() {
      if (isDihybrid) {
        // Дигибридное скрещивание (2 признака)
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
        // Моногибридное скрещивание (1 признак)
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

      // 💾 Сохраняем результат в историю
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

  // 🎲 Случайный эксперимент (генерирует случайные параметры)
  void _randomExperiment() {
    setState(() {
      final traits = TraitConfig.availableTraits;
      final random = DateTime.now().millisecond;
      trait1 = traits[random % traits.length];
      trait2 = traits[(random + 1) % traits.length];
      final genotypes = ['AA', 'Aa', 'aa'];
      final bGenotypes = ['BB', 'Bb', 'bb'];
      p1t1 = genotypes[random % 3];
      p2t1 = genotypes[(random + 4) % 3];
      if (isDihybrid) {
        p1t2 = bGenotypes[(random + 2) % 3];
        p2t2 = bGenotypes[(random + 6) % 3];
      }
      hasResults = false;
    });
  }

  // 🧬 Определение фенотипа по генотипу
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

  // ════════════════════════════════════════════════════════════════════════════
  // 📄 ЭКСПОРТ В PDF
  // ════════════════════════════════════════════════════════════════════════════
  
  // 📄 Генерация и скачивание PDF
  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    final font = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(font);
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Генетика: Результаты скрещивания',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf)),
            pw.SizedBox(height: 20),
            pw.Text('Режим: ${isDihybrid ? "Дигибридное (2 признака)" : "Моногибридное (1 признак)"}',
                style: pw.TextStyle(fontSize: 16, font: ttf)),
            pw.Text('Признак 1: ${trait1.name} (A/a)',
                style: pw.TextStyle(fontSize: 14, font: ttf)),
            if (isDihybrid)
              pw.Text('Признак 2: ${trait2.name} (B/b)',
                  style: pw.TextStyle(fontSize: 14, font: ttf)),
            pw.SizedBox(height: 16),
            pw.Text('Родители:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: ttf)),
            pw.Text('Родитель 1: ${isDihybrid ? "$p1t1/$p1t2" : p1t1}',
                style: pw.TextStyle(fontSize: 14, font: ttf)),
            pw.Text('Родитель 2: ${isDihybrid ? "$p2t1/$p2t2" : p2t1}',
                style: pw.TextStyle(fontSize: 14, font: ttf)),
            pw.SizedBox(height: 16),
            pw.Text('Решётка Пеннета:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: ttf)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(),
              children: _buildPdfPunnettTable(ttf),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Результаты:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: ttf)),
            ...results.entries.map((e) {
              final total = isDihybrid ? 16 : 4;
              final pct = (e.value / total * 100).toInt();
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text('• Генотип ${e.key}: $pct% — ${_getPhenotype(e.key)}',
                    style: pw.TextStyle(fontSize: 12, font: ttf)),
              );
            }),
          ],
        ),
      ),
    );
    
    // Создаём байты PDF
    final bytes = await pdf.save();
    
    // Скачиваем файл напрямую (без диалога печати)
    await Printing.sharePdf(bytes: bytes, filename: 'genetics_result.pdf');
  }
  
  // 📊 Построение таблицы для PDF
  List<pw.TableRow> _buildPdfPunnettTable(pw.Font ttf) {
    final size = isDihybrid ? 4 : 2;
    final rows = <pw.TableRow>[];
    final topHeaders = isDihybrid 
        ? ['${p1t1[0]}${p1t2[0]}', '${p1t1[0]}${p1t2[1]}', '${p1t1[1]}${p1t2[0]}', '${p1t1[1]}${p1t2[1]}']
        : [p1t1[0].toString(), p1t1[1].toString()];
    
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: const pw.EdgeInsets.all(4)),
        ...topHeaders.map((h) => pw.Container(
          padding: const pw.EdgeInsets.all(4),
          alignment: pw.Alignment.center,
          child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf)),
        )),
      ],
    ));
    
    for (int i = 0; i < size; i++) {
      final leftHeader = isDihybrid
          ? ['${p2t1[0]}${p2t2[0]}', '${p2t1[0]}${p2t2[1]}', '${p2t1[1]}${p2t2[0]}', '${p2t1[1]}${p2t2[1]}'][i]
          : [p2t1[0].toString(), p2t1[1].toString()][i];
      
      rows.add(pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(4),
            alignment: pw.Alignment.center,
            child: pw.Text(leftHeader, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf)),
          ),
          for (int j = 0; j < size; j++)
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              alignment: pw.Alignment.center,
              child: pw.Text(punnettGrid[i * size + j], style: pw.TextStyle(font: ttf)),
            ),
        ],
      ));
    }
    return rows;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🎨 ПОСТРОЕНИЕ ИНТЕРФЕЙСА (UI)
  // ════════════════════════════════════════════════════════════════════════════
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ────────────────────────────────────────────────────────────────────────
      // 🔝 ШАПКА ПРИЛОЖЕНИЯ (AppBar)
      // ────────────────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('🧬 Генетика для начинающих', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        actions: [
          // Кнопка "Теория"
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TheoryScreen()),
            ),
            child: const Text('📖 Теория',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          // Кнопка "История"
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
      
      // ────────────────────────────────────────────────────────────────────────
      // 📋 ОСНОВНОЕ ТЕЛО ЭКРАНА (прокручиваемое)
      // ────────────────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🎛 КАРТОЧКА: Выбор режима скрещивания (Моно/Ди)
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
              
              // 🎲 КНОПКА: Случайный эксперимент (для обоих режимов)
              ElevatedButton.icon(
                onPressed: _randomExperiment,
                icon: const Icon(Icons.casino),
                label: const Text('🎲 Случайный эксперимент'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[300],
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // 🧬 ВЫБОР ПРИЗНАКОВ (только для "Ди")
              if (isDihybrid) ...[
                _buildDropdown('Признак 1 (A/a)', trait1, (v) => setState(() { trait1 = v; hasResults = false; })),
                const SizedBox(height: 8),
                _buildDropdown('Признак 2 (B/b)', trait2, (v) => setState(() { trait2 = v; hasResults = false; })),
                const SizedBox(height: 16),
              ],

              // 👨‍👩‍👧 КАРТОЧКИ РОДИТЕЛЕЙ
              _buildParent('Родитель 1', p1t1, p1t2, (g1, g2) => setState(() { p1t1 = g1; p1t2 = g2; hasResults = false; })),
              const SizedBox(height: 12),
              _buildParent('Родитель 2', p2t1, p2t2, (g1, g2) => setState(() { p2t1 = g1; p2t2 = g2; hasResults = false; })),
              const SizedBox(height: 20),

              // 🧬 КНОПКА: Запустить скрещивание
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
              const SizedBox(height: 12),
              
              // 📄 КНОПКА: Скачать PDF (появляется только после скрещивания)
              if (hasResults)
                ElevatedButton.icon(
                  onPressed: _downloadPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('📄 Скачать PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(height: 20),

              // 📊 РЕЗУЛЬТАТЫ СКРЕЩИВАНИЯ (показываются после нажатия "Скрестить")
              if (hasResults) ...[
                // Заголовок решётки
                Text(
                  isDihybrid ? '🧩 Решётка Пеннета (4×4)' : '🧩 Решётка Пеннета (2×2)',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildGrid(), // Сама решётка
                const SizedBox(height: 20),
                _buildChart(), // Диаграмма (круг или столбцы)
                const SizedBox(height: 16),
                _buildStats(), // Список результатов с процентами
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🧩 ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ (функции для построения UI)
  // ════════════════════════════════════════════════════════════════════════════
  
  // 🔽 Выпадающий список выбора признака
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

  // 👨‍👩‍👧 Карточка родителя с выбором генотипов
  Widget _buildParent(String title, String t1, String t2, void Function(String, String) onChange) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // 🔤 Выпадающий список генотипа (AA, Aa, aa или BB, Bb, bb)
  Widget _buildGeno(String value, String letter, ValueChanged<String> onChange) {
    final opts = letter == 'B' ? ['BB', 'Bb', 'bb'] : ['AA', 'Aa', 'aa'];
    return DropdownButton<String>(
      value: value,
      style: const TextStyle(fontSize: 16),
      items: opts.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: (v) => v != null ? onChange(v) : null,
    );
  }

  // 🧩 Решётка Пеннета (визуальная таблица)
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

  // 📊 Диаграмма генотипов (круговая или столбчатая)
  Widget _buildChart() {
    final useBarChart = results.length > 5; // Если много генотипов — столбцы
    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('📊 Генотипы', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (useBarChart)
              // 📊 СТОЛБЧАТАЯ ДИАГРАММА
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    groupsSpace: 12,
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
              // 🥧 КРУГОВАЯ ДИАГРАММА
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

  // 📈 Список результатов с процентами и фенотипами
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

  // 🎨 Определение цвета для генотипа
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