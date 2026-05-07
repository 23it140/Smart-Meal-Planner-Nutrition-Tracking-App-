import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_item_model.dart';
import '../models/meal_entry_model.dart';
import '../models/nutrition_goal_model.dart';
import 'food_database_service.dart';

class HiveService {
  static const String foodItemsBox = 'food_items';
  static const String mealEntriesBox = 'meal_entries';
  static const String nutritionGoalsBox = 'nutrition_goals';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FoodItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MealEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(NutritionGoalAdapter());
    }

    // Open boxes
    await Hive.openBox<FoodItem>(foodItemsBox);
    await Hive.openBox<MealEntry>(mealEntriesBox);
    await Hive.openBox<NutritionGoal>(nutritionGoalsBox);

    // Seed food database if empty or merge new items
    final box = Hive.box<FoodItem>(foodItemsBox);
    final defaults = FoodDatabaseService.defaultFoods();
    for (final food in defaults) {
      if (!box.containsKey(food.id)) {
        await box.put(food.id, food);
      }
    }

    // Seed default goal if none
    final goalBox = Hive.box<NutritionGoal>(nutritionGoalsBox);
    if (goalBox.isEmpty) {
      await goalBox.put('default', NutritionGoal(
        id: 'default',
        targetCalories: 2000,
        targetProtein: 50,
        targetCarbs: 250,
        targetFats: 65,
        updatedAt: DateTime.now(),
      ));
    }
  }

  static Box<FoodItem> get foodBox => Hive.box<FoodItem>(foodItemsBox);
  static Box<MealEntry> get mealBox => Hive.box<MealEntry>(mealEntriesBox);
  static Box<NutritionGoal> get goalBox => Hive.box<NutritionGoal>(nutritionGoalsBox);
}
