import 'package:hive/hive.dart';

part 'meal_entry_model.g.dart';

@HiveType(typeId: 1)
class MealEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String foodItemId;

  @HiveField(2)
  String foodItemName;

  @HiveField(3)
  String mealType; // Breakfast, Lunch, Dinner, Snacks

  @HiveField(4)
  double quantity;

  @HiveField(5)
  double calories;

  @HiveField(6)
  double protein;

  @HiveField(7)
  double carbs;

  @HiveField(8)
  double fats;

  @HiveField(9)
  DateTime date;

  @HiveField(10)
  bool isSynced;

  @HiveField(11)
  String unit;

  MealEntry({
    required this.id,
    required this.foodItemId,
    required this.foodItemName,
    required this.mealType,
    required this.quantity,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    required this.date,
    this.isSynced = false,
    this.unit = 'g',
  });

  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
