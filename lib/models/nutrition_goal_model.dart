import 'package:hive/hive.dart';

part 'nutrition_goal_model.g.dart';

@HiveType(typeId: 2)
class NutritionGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double targetCalories;

  @HiveField(2)
  double targetProtein;

  @HiveField(3)
  double targetCarbs;

  @HiveField(4)
  double targetFats;

  @HiveField(5)
  DateTime updatedAt;

  NutritionGoal({
    required this.id,
    this.targetCalories = 2000,
    this.targetProtein = 50,
    this.targetCarbs = 250,
    this.targetFats = 65,
    required this.updatedAt,
  });

  double get totalMacroCalories =>
      (targetProtein * 4) + (targetCarbs * 4) + (targetFats * 9);
}
