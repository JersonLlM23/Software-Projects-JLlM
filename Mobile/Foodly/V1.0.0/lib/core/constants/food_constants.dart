/// Initial predefined food reference data and units.
class FoodConstants {
  FoodConstants._();

  // Supported units for v1.0.0
  static const String unitGrams = 'g';
  static const String unitMilliliters = 'ml';
  static const String unitItem = 'unidad';

  // Predefined initial food items (Centralized energy reference)
  static const List<Map<String, dynamic>> initialFoodsData = [
    {
      'id': 'food_arroz',
      'name': 'Arroz',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 130.0,
      'icon': '🌾',
    },
    {
      'id': 'food_carne',
      'name': 'Carne',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 250.0,
      'icon': '🥩',
    },
    {
      'id': 'food_pollo_cocinado_agua',
      'name': 'Pollo cocinado con agua',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 165.0,
      'icon': '🍗',
    },
    {
      'id': 'food_pollo_frito',
      'name': 'Pollo frito',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 260.0,
      'icon': '🍗',
    },
    {
      'id': 'food_pollo_broaster',
      'name': 'Pollo broaster',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 290.0,
      'icon': '🍗',
    },
    {
      'id': 'food_tomate',
      'name': 'Tomate',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 18.0,
      'icon': '🍅',
    },
    {
      'id': 'food_lechuga',
      'name': 'Lechuga',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 15.0,
      'icon': '🥬',
    },
    {
      'id': 'food_remolacha',
      'name': 'Remolacha',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 43.0,
      'icon': '🟣',
    },
    {
      'id': 'food_agua',
      'name': 'Agua',
      'servingAmount': 100.0,
      'servingUnit': unitMilliliters,
      'energyKcal': 0.0,
      'icon': '💧',
    },
    {
      'id': 'food_jugo_mora',
      'name': 'Jugo de mora',
      'servingAmount': 100.0,
      'servingUnit': unitMilliliters,
      'energyKcal': 45.0,
      'icon': '🥤',
    },
    {
      'id': 'food_babaco',
      'name': 'Babaco',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 25.0,
      'icon': '🍈',
    },
    {
      'id': 'food_papas_fritas',
      'name': 'Papas fritas',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 312.0,
      'icon': '🍟',
    },
    {
      'id': 'food_salchicha',
      'name': 'Salchicha',
      'servingAmount': 1.0,
      'servingUnit': unitItem,
      'energyKcal': 150.0,
      'icon': '🌭',
    },
    {
      'id': 'food_carne_cocinada',
      'name': 'Carne cocinada',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 220.0,
      'icon': '🥩',
    },
    {
      'id': 'food_chuleta',
      'name': 'Chuleta',
      'servingAmount': 100.0,
      'servingUnit': unitGrams,
      'energyKcal': 230.0,
      'icon': '🥩',
    },
  ];
}
