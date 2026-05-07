import 'package:hive/hive.dart';

part 'food_item_model.g.dart';

@HiveType(typeId: 0)
class FoodItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double caloriesPer100g;

  @HiveField(3)
  double proteinPer100g;

  @HiveField(4)
  double carbsPer100g;

  @HiveField(5)
  double fatsPer100g;

  @HiveField(6)
  String category;

  @HiveField(7)
  bool isCustom;

  @HiveField(8)
  String unit; // 'g', 'ml', 'piece'

  FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    this.proteinPer100g = 0,
    this.carbsPer100g = 0,
    this.fatsPer100g = 0,
    this.category = 'Other',
    this.isCustom = false,
    this.unit = 'g',
  });

  double getCalories(double quantity) => (caloriesPer100g * quantity) / 100;
  double getProtein(double quantity) => (proteinPer100g * quantity) / 100;
  double getCarbs(double quantity) => (carbsPer100g * quantity) / 100;
  double getFats(double quantity) => (fatsPer100g * quantity) / 100;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatsPer100g': fatsPer100g,
        'category': category,
        'isCustom': isCustom,
        'unit': unit,
      };
}
