import '../models/allele.dart';
import '../models/organism.dart';

class GeneticsEngine {
  /// Моногибридное скрещивание (2×2)
  static Map<String, int> crossMono(Organism parent1, Organism parent2) {
    final gametes1 = [parent1.allele1, parent1.allele2];
    final gametes2 = [parent2.allele1, parent2.allele2];
    final results = <String, int>{};

    for (final g1 in gametes1) {
      for (final g2 in gametes2) {
        final child = Organism(g1, g2);
        final key = child.genotype;
        results[key] = (results[key] ?? 0) + 1;
      }
    }
    return results;
  }

  /// Дигибридное скрещивание (4×4)
  /// Принимает генотипы двух признаков для каждого родителя (например, "Aa", "Bb")
  static Map<String, int> crossDi(
      String trait1P1, String trait2P1, String trait1P2, String trait2P2) {
    // Формируем гаметы: [A,B], [A,b], [a,B], [a,b]
    List<String> getGametes(String t1, String t2) {
      return [
        '${t1[0]}${t2[0]}',
        '${t1[0]}${t2[1]}',
        '${t1[1]}${t2[0]}',
        '${t1[1]}${t2[1]}',
      ];
    }

    final gametes1 = getGametes(trait1P1, trait2P1);
    final gametes2 = getGametes(trait1P2, trait2P2);
    final results = <String, int>{};

    for (final g1 in gametes1) {
      for (final g2 in gametes2) {
        // Собираем генотип потомка, сортируем аллели для красоты (AaBb, а не aABb)
        String combine(String a1, String a2) {
          final sorted = [a1, a2]..sort();
          return sorted.join();
        }
        final childGenotype = '${combine(g1[0], g2[0])}${combine(g1[1], g2[1])}';
        results[childGenotype] = (results[childGenotype] ?? 0) + 1;
      }
    }
    return results;
  }

  /// Фенотип для одного признака
  static String getPhenotypeMono(String genotype) {
    return genotype.contains('A') ? 'Доминантный' : 'Рецессивный';
  }

  /// Фенотип для двух признаков
  static String getPhenotypeDi(String genotype, String domLabel1, String recLabel1, String domLabel2, String recLabel2) {
    final t1 = genotype.substring(0, 2);
    final t2 = genotype.substring(2, 4);
    final p1 = t1.contains('A') ? domLabel1 : recLabel1;
    final p2 = t2.contains('B') ? domLabel2 : recLabel2;
    return '$p1, $p2';
  }
}