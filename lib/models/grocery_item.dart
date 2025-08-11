import 'package:shopping_list/models/category.dart';

class GroceryItem {
  final String id;
  final String name;
  final Category category;
  final int quantity;

  const GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
  });
}
