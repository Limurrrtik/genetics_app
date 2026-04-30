import '../models/allele.dart';
import '../models/organism.dart';

class GeneticsEngine {
  /// Моногибридное скрещивание (Решётка Пеннета)
  static Map<String, int> cross(Organism parent1, Organism parent2) {
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

  /// Определяет фенотип по генотипу
  static String getPhenotype(String genotype) {
    if (genotype.contains('A')) {
      return 'Доминантный';
    }
    return 'Рецессивный';
  }
}