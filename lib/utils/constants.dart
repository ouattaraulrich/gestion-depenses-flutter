class AppCategories {
  static const List<Map<String, String>> categories = [
    {'name': 'Nourriture', 'icon': '🍔'},
    {'name': 'Transport', 'icon': '🚕'},
    {'name': 'Maison', 'icon': '🏠'},
    {'name': 'Études', 'icon': '📚'},
    {'name': 'Internet', 'icon': '📱'},
    {'name': 'Factures', 'icon': '💡'},
    {'name': 'Loisirs', 'icon': '🎮'},
    {'name': 'Santé', 'icon': '❤️'},
    {'name': 'Vêtements', 'icon': '👕'},
    {'name': 'Autres', 'icon': '📦'},
  ];

  static String getIcon(String category) {
    final found = categories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => {'name': category, 'icon': '📦'},
    );
    return found['icon']!;
  }
}