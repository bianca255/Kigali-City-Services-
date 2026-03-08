class AppCategories {
  AppCategories._();

  static const List<String> all = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Utility Office',
  ];

  static const Map<String, String> icons = {
    'Hospital': '🏥',
    'Police Station': '🚓',
    'Library': '📚',
    'Restaurant': '🍽️',
    'Café': '☕',
    'Park': '🌳',
    'Tourist Attraction': '🏛️',
    'Utility Office': '🏢',
  };

  static String iconFor(String category) => icons[category] ?? '📍';
}
