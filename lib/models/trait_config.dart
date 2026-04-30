class TraitConfig {
  final String name;
  final String dominantLabel;
  final String recessiveLabel;

  const TraitConfig({
    required this.name,
    required this.dominantLabel,
    required this.recessiveLabel,
  });

  // Список доступных признаков
  static const List<TraitConfig> availableTraits = [
    TraitConfig(
      name: '🟢 Цвет гороха (Мендель)',
      dominantLabel: 'Зелёный',
      recessiveLabel: 'Жёлтый',
    ),
    TraitConfig(
      name: '👁️ Цвет глаз',
      dominantLabel: 'Карий',
      recessiveLabel: 'Голубой',
    ),
    TraitConfig(
      name: ' Резус-фактор',
      dominantLabel: 'Положительный (+)',
      recessiveLabel: 'Отрицательный (-)',
    ),
        TraitConfig(
      name: '🟤 Форма гороха (Мендель)',
      dominantLabel: 'Гладкий',
      recessiveLabel: 'Морщинистый',
    ),
  ];
}