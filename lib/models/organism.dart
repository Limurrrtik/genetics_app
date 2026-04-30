import 'allele.dart';

class Organism {
  final Allele allele1;
  final Allele allele2;

  const Organism(this.allele1, this.allele2);

  String get genotype => '${allele1.symbol}${allele2.symbol}';
  
  String get phenotype =>
      (allele1 == Allele.dominant || allele2 == Allele.dominant)
          ? 'Доминантный'
          : 'Рецессивный';
}