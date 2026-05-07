import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_entry_model.dart';
import '../models/food_item_model.dart';
import '../models/nutrition_goal_model.dart';
import '../services/hive_service.dart';

const _uuid = Uuid();

// ─── Selected Date Provider ───────────────────────────────────────────────────
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ─── Meal Entries Notifier ────────────────────────────────────────────────────
class MealEntriesNotifier extends StateNotifier<List<MealEntry>> {
  MealEntriesNotifier() : super([]) {
    _loadAll();
  }

  void _loadAll() {
    state = HiveService.mealBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addEntry({
    required FoodItem food,
    required String mealType,
    required double quantity,
    required DateTime date,
  }) async {
    final entry = MealEntry(
      id: _uuid.v4(),
      foodItemId: food.id,
      foodItemName: food.name,
      mealType: mealType,
      quantity: quantity,
      calories: food.getCalories(quantity),
      protein: food.getProtein(quantity),
      carbs: food.getCarbs(quantity),
      fats: food.getFats(quantity),
      date: date,
      unit: food.unit,
    );
    await HiveService.mealBox.put(entry.id, entry);
    _loadAll();
  }

  Future<void> deleteEntry(String id) async {
    await HiveService.mealBox.delete(id);
    _loadAll();
  }

  Future<void> updateEntry(MealEntry entry) async {
    await HiveService.mealBox.put(entry.id, entry);
    _loadAll();
  }

  List<MealEntry> getEntriesForDate(DateTime date) {
    final key = _dateKey(date);
    return state.where((e) => e.dateKey == key).toList();
  }

  List<MealEntry> getEntriesForDateAndType(DateTime date, String mealType) {
    return getEntriesForDate(date)
        .where((e) => e.mealType == mealType)
        .toList();
  }

  DailyNutrition getDailyTotals(DateTime date) {
    final entries = getEntriesForDate(date);
    return DailyNutrition(
      calories: entries.fold(0, (s, e) => s + e.calories),
      protein: entries.fold(0, (s, e) => s + e.protein),
      carbs: entries.fold(0, (s, e) => s + e.carbs),
      fats: entries.fold(0, (s, e) => s + e.fats),
      date: date,
    );
  }

  List<DailyNutrition> getWeeklyData() {
    final List<DailyNutrition> result = [];
    final today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      result.add(getDailyTotals(day));
    }
    return result;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

final mealEntriesProvider =
    StateNotifierProvider<MealEntriesNotifier, List<MealEntry>>(
  (ref) => MealEntriesNotifier(),
);

// ─── Derived Providers ────────────────────────────────────────────────────────
final dailyEntriesProvider = Provider<List<MealEntry>>((ref) {
  final date = ref.watch(selectedDateProvider);
  final notifier = ref.watch(mealEntriesProvider.notifier);
  return notifier.getEntriesForDate(date);
});

final dailyTotalsProvider = Provider<DailyNutrition>((ref) {
  final date = ref.watch(selectedDateProvider);
  final notifier = ref.watch(mealEntriesProvider.notifier);
  ref.watch(mealEntriesProvider); // rebuild when entries change
  return notifier.getDailyTotals(date);
});

final weeklyDataProvider = Provider<List<DailyNutrition>>((ref) {
  ref.watch(mealEntriesProvider); // rebuild when entries change
  return ref.read(mealEntriesProvider.notifier).getWeeklyData();
});

// ─── Nutrition Goal Provider ──────────────────────────────────────────────────
class NutritionGoalNotifier extends StateNotifier<NutritionGoal> {
  NutritionGoalNotifier()
      : super(NutritionGoal(
          id: 'default',
          updatedAt: DateTime.now(),
        )) {
    _load();
  }

  void _load() {
    final goal = HiveService.goalBox.get('default');
    if (goal != null) state = goal;
  }

  Future<void> updateGoal({
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
  }) async {
    final updated = NutritionGoal(
      id: 'default',
      targetCalories: calories ?? state.targetCalories,
      targetProtein: protein ?? state.targetProtein,
      targetCarbs: carbs ?? state.targetCarbs,
      targetFats: fats ?? state.targetFats,
      updatedAt: DateTime.now(),
    );
    await HiveService.goalBox.put('default', updated);
    state = updated;
  }
}

final nutritionGoalProvider =
    StateNotifierProvider<NutritionGoalNotifier, NutritionGoal>(
  (ref) => NutritionGoalNotifier(),
);

// ─── Food Items Provider ──────────────────────────────────────────────────────
class FoodItemsNotifier extends StateNotifier<List<FoodItem>> {
  FoodItemsNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.foodBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> addCustomFood(FoodItem food) async {
    await HiveService.foodBox.put(food.id, food);
    _load();
  }

  Future<void> deleteCustomFood(String id) async {
    final food = HiveService.foodBox.get(id);
    if (food != null && food.isCustom) {
      await HiveService.foodBox.delete(id);
      _load();
    }
  }
}

final foodItemsProvider =
    StateNotifierProvider<FoodItemsNotifier, List<FoodItem>>(
  (ref) => FoodItemsNotifier(),
);

// ─── Search & Filter Providers ────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
final selectedMealTypeFilterProvider = StateProvider<String>((ref) => 'All');

final filteredFoodItemsProvider = Provider<List<FoodItem>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final allFoods = ref.watch(foodItemsProvider);

  var filtered = allFoods;
  if (category != 'All') {
    filtered = filtered.where((f) => f.category == category).toList();
  }
  if (query.isNotEmpty) {
    final lower = query.toLowerCase();
    filtered = filtered.where((f) => f.name.toLowerCase().contains(lower)).toList();
  }
  return filtered;
});

final filteredMealEntriesProvider = Provider<List<MealEntry>>((ref) {
  final mealTypeFilter = ref.watch(selectedMealTypeFilterProvider);
  final date = ref.watch(selectedDateProvider);
  final notifier = ref.watch(mealEntriesProvider.notifier);
  ref.watch(mealEntriesProvider);

  var entries = notifier.getEntriesForDate(date);
  if (mealTypeFilter != 'All') {
    entries = entries.where((e) => e.mealType == mealTypeFilter).toList();
  }
  return entries;
});

// ─── Daily Nutrition Model ────────────────────────────────────────────────────
class DailyNutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime date;

  const DailyNutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
  });
}
