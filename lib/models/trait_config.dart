class TraitConfig {
  final String name;
  final String dominantLabel;
  final String recessiveLabel;
  final String category;

  const TraitConfig({
    required this.name,
    required this.dominantLabel,
    required this.recessiveLabel,
    required this.category,
  });

  static const List<TraitConfig> availableTraits = [
    // Признаки гороха (Мендель)
    TraitConfig(
      name: 'Цвет гороха',
      dominantLabel: 'Зелёный',
      recessiveLabel: 'Жёлтый',
      category: 'pea',
    ),
    TraitConfig(
      name: 'Форма гороха',
      dominantLabel: 'Гладкий',
      recessiveLabel: 'Морщинистый',
      category: 'pea',
    ),
    TraitConfig(
      name: 'Высота стебля',
      dominantLabel: 'Высокий',
      recessiveLabel: 'Карликовый',
      category: 'pea',
    ),
    TraitConfig(
      name: 'Окраска цветков',
      dominantLabel: 'Фиолетовый',
      recessiveLabel: 'Белый',
      category: 'pea',
    ),
    TraitConfig(
      name: 'Форма стручков',
      dominantLabel: 'Гладкие',
      recessiveLabel: 'Морщинистые',
      category: 'pea',
    ),
    TraitConfig(
      name: 'Цвет стручков',
      dominantLabel: 'Зелёные',
      recessiveLabel: 'Жёлтые',
      category: 'pea',
    ),
    TraitConfig(
      name: 'Расположение цветков',
      dominantLabel: 'Пазушные',
      recessiveLabel: 'Верхушечные',
      category: 'pea',
    ),
    
    // Человеческие признаки
    TraitConfig(
      name: 'Цвет глаз',
      dominantLabel: 'Карий',
      recessiveLabel: 'Голубой',
      category: 'human',
    ),
    TraitConfig(
      name: 'Волосы',
      dominantLabel: 'Вьющиеся',
      recessiveLabel: 'Прямые',
      category: 'human',
    ),
    TraitConfig(
      name: 'Язык',
      dominantLabel: 'Сворачивает в трубочку',
      recessiveLabel: 'Не сворачивает',
      category: 'human',
    ),
    TraitConfig(
      name: 'Мочка уха',
      dominantLabel: 'Свободная',
      recessiveLabel: 'Приросшая',
      category: 'human',
    ),
    TraitConfig(
      name: 'Подбородок',
      dominantLabel: 'С ямочкой',
      recessiveLabel: 'Без ямочки',
      category: 'human',
    ),
  ];
}