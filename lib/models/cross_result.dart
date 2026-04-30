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
}