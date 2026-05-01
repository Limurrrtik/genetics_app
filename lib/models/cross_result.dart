import 'organism.dart';
import 'allele.dart';
import 'trait_config.dart';

class CrossResult {
  final DateTime timestamp;
  final bool isDihybrid;
  final TraitConfig trait1;
  final TraitConfig? trait2;
  final String parent1T1, parent1T2;
  final String parent2T1, parent2T2;
  final Map<String, int> offspring;

  CrossResult({
    required this.timestamp,
    required this.isDihybrid,
    required this.trait1,
    this.trait2,
    required this.parent1T1,
    required this.parent1T2,
    required this.parent2T1,
    required this.parent2T2,
    required this.offspring,
  });

  String get summary {
    final p1 = isDihybrid ? '$parent1T1/$parent1T2' : parent1T1;
    final p2 = isDihybrid ? '$parent2T1/$parent2T2' : parent2T1;
    final traitName = trait1.name.split(' ').first;
    return '$traitName: $p1 × $p2 → ${offspring.length} генотип(ов)';
  }
    // Определяем тип зиготности
  String getZygosity(String genotype) {
    // Если режим "Моно" (AA, Aa, aa)
    if (!isDihybrid) {
      if (genotype == 'AA' || genotype == 'aa') {
        return '🛡️ Гомозигота';
      }
      return '🔄 Гетерозигота';
    }
    
    // Если режим "Ди" (AABB, AaBb и т.д.)
    final t1 = genotype.substring(0, 2); // Первые две буквы (A/a)
    final t2 = genotype.substring(2, 4); // Вторые две буквы (B/b)
    
    bool isHomo1 = (t1[0] == t1[1]);
    bool isHomo2 = (t2[0] == t2[1]);
    
    if (isHomo1 && isHomo2) {
      return '🛡️ Гомозигота (по обоим признакам)';
    } else if (!isHomo1 && !isHomo2) {
      return '🔄 Дигетерозигота';
    } else {
      return '🔄 Гетерозигота (по одному признаку)';
    }
  }
}