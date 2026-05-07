import 'package:hive/hive.dart';
import '../models/food_item_model.dart';

class FoodDatabaseService {
  static Future<void> seedDatabase(Box<FoodItem> box) async {
    final foods = defaultFoods();
    for (final food in foods) {
      await box.put(food.id, food);
    }
  }

  static List<FoodItem> defaultFoods() {
    return [
      // Grains & Cereals
      FoodItem(id: 'rice_white', name: 'White Rice (Cooked)', caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28.2, fatsPer100g: 0.3, category: 'Grains'),
      FoodItem(id: 'rice_brown', name: 'Brown Rice (Cooked)', caloriesPer100g: 111, proteinPer100g: 2.6, carbsPer100g: 23, fatsPer100g: 0.9, category: 'Grains'),
      FoodItem(id: 'bread_white', name: 'White Bread', caloriesPer100g: 265, proteinPer100g: 9, carbsPer100g: 49, fatsPer100g: 3.2, category: 'Grains'),
      FoodItem(id: 'bread_wheat', name: 'Whole Wheat Bread', caloriesPer100g: 247, proteinPer100g: 13, carbsPer100g: 41, fatsPer100g: 4.2, category: 'Grains'),
      FoodItem(id: 'oats', name: 'Oats (Cooked)', caloriesPer100g: 71, proteinPer100g: 2.5, carbsPer100g: 12, fatsPer100g: 1.4, category: 'Grains'),
      FoodItem(id: 'chapati', name: 'Chapati / Roti', caloriesPer100g: 297, proteinPer100g: 9.5, carbsPer100g: 55, fatsPer100g: 4, category: 'Grains'),
      FoodItem(id: 'pasta', name: 'Pasta (Cooked)', caloriesPer100g: 131, proteinPer100g: 5, carbsPer100g: 25, fatsPer100g: 1.1, category: 'Grains'),
      FoodItem(id: 'poha', name: 'Poha (Flattened Rice)', caloriesPer100g: 333, proteinPer100g: 7, carbsPer100g: 77, fatsPer100g: 0.5, category: 'Grains'),

      // Proteins
      FoodItem(id: 'chicken_breast', name: 'Chicken Breast (Cooked)', caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatsPer100g: 3.6, category: 'Protein'),
      FoodItem(id: 'eggs', name: 'Egg (Whole)', caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatsPer100g: 11, category: 'Protein', unit: 'piece'),
      FoodItem(id: 'dal_lentils', name: 'Dal / Lentils (Cooked)', caloriesPer100g: 116, proteinPer100g: 9, carbsPer100g: 20, fatsPer100g: 0.4, category: 'Protein'),
      FoodItem(id: 'paneer', name: 'Paneer (Cottage Cheese)', caloriesPer100g: 265, proteinPer100g: 18, carbsPer100g: 3.4, fatsPer100g: 20, category: 'Protein'),
      FoodItem(id: 'tofu', name: 'Tofu', caloriesPer100g: 76, proteinPer100g: 8, carbsPer100g: 1.9, fatsPer100g: 4.8, category: 'Protein'),
      FoodItem(id: 'fish_salmon', name: 'Salmon (Cooked)', caloriesPer100g: 208, proteinPer100g: 20, carbsPer100g: 0, fatsPer100g: 13, category: 'Protein'),
      FoodItem(id: 'chickpeas', name: 'Chickpeas (Cooked)', caloriesPer100g: 164, proteinPer100g: 8.9, carbsPer100g: 27, fatsPer100g: 2.6, category: 'Protein'),
      FoodItem(id: 'chole', name: 'Chole (Chana Masala)', caloriesPer100g: 138, proteinPer100g: 7.5, carbsPer100g: 22, fatsPer100g: 2.5, category: 'Protein'),

      // Dairy
      FoodItem(id: 'milk_whole', name: 'Whole Milk', caloriesPer100g: 61, proteinPer100g: 3.2, carbsPer100g: 4.8, fatsPer100g: 3.3, category: 'Dairy', unit: 'ml'),
      FoodItem(id: 'curd_yogurt', name: 'Curd / Yogurt', caloriesPer100g: 59, proteinPer100g: 3.5, carbsPer100g: 4.7, fatsPer100g: 3.3, category: 'Dairy'),
      FoodItem(id: 'cheese', name: 'Cheese', caloriesPer100g: 402, proteinPer100g: 25, carbsPer100g: 1.3, fatsPer100g: 33, category: 'Dairy'),
      FoodItem(id: 'ghee', name: 'Ghee', caloriesPer100g: 900, proteinPer100g: 0, carbsPer100g: 0, fatsPer100g: 100, category: 'Dairy'),

      // Vegetables
      FoodItem(id: 'spinach', name: 'Spinach', caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatsPer100g: 0.4, category: 'Vegetables'),
      FoodItem(id: 'broccoli', name: 'Broccoli', caloriesPer100g: 34, proteinPer100g: 2.8, carbsPer100g: 6.6, fatsPer100g: 0.4, category: 'Vegetables'),
      FoodItem(id: 'potato', name: 'Potato (Boiled)', caloriesPer100g: 87, proteinPer100g: 1.9, carbsPer100g: 20, fatsPer100g: 0.1, category: 'Vegetables'),
      FoodItem(id: 'tomato', name: 'Tomato', caloriesPer100g: 18, proteinPer100g: 0.9, carbsPer100g: 3.9, fatsPer100g: 0.2, category: 'Vegetables'),
      FoodItem(id: 'onion', name: 'Onion', caloriesPer100g: 40, proteinPer100g: 1.1, carbsPer100g: 9.3, fatsPer100g: 0.1, category: 'Vegetables'),
      FoodItem(id: 'carrot', name: 'Carrot', caloriesPer100g: 41, proteinPer100g: 0.9, carbsPer100g: 10, fatsPer100g: 0.2, category: 'Vegetables'),
      FoodItem(id: 'cucumber', name: 'Cucumber', caloriesPer100g: 15, proteinPer100g: 0.7, carbsPer100g: 3.6, fatsPer100g: 0.1, category: 'Vegetables'),

      // Fruits
      FoodItem(id: 'banana', name: 'Banana', caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatsPer100g: 0.3, category: 'Fruits'),
      FoodItem(id: 'apple', name: 'Apple', caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatsPer100g: 0.2, category: 'Fruits'),
      FoodItem(id: 'mango', name: 'Mango', caloriesPer100g: 60, proteinPer100g: 0.8, carbsPer100g: 15, fatsPer100g: 0.4, category: 'Fruits'),
      FoodItem(id: 'orange', name: 'Orange', caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 12, fatsPer100g: 0.1, category: 'Fruits'),
      FoodItem(id: 'grapes', name: 'Grapes', caloriesPer100g: 67, proteinPer100g: 0.6, carbsPer100g: 17, fatsPer100g: 0.4, category: 'Fruits'),

      // Snacks
      FoodItem(id: 'samosa', name: 'Samosa', caloriesPer100g: 262, proteinPer100g: 5, carbsPer100g: 32, fatsPer100g: 13, category: 'Snacks', unit: 'piece'),
      FoodItem(id: 'biscuits', name: 'Biscuits / Cookies', caloriesPer100g: 458, proteinPer100g: 6, carbsPer100g: 64, fatsPer100g: 20, category: 'Snacks'),
      FoodItem(id: 'nuts_mixed', name: 'Mixed Nuts', caloriesPer100g: 607, proteinPer100g: 20, carbsPer100g: 21, fatsPer100g: 54, category: 'Snacks'),
      FoodItem(id: 'idli', name: 'Idli', caloriesPer100g: 58, proteinPer100g: 2, carbsPer100g: 12, fatsPer100g: 0.4, category: 'Snacks', unit: 'piece'),
      FoodItem(id: 'dosa', name: 'Dosa (Plain)', caloriesPer100g: 168, proteinPer100g: 3.9, carbsPer100g: 33, fatsPer100g: 2.2, category: 'Snacks'),

      // Beverages
      FoodItem(id: 'chai_tea', name: 'Chai (with milk & sugar)', caloriesPer100g: 40, proteinPer100g: 1.5, carbsPer100g: 5, fatsPer100g: 1.5, category: 'Beverages', unit: 'ml'),
      FoodItem(id: 'coffee_black', name: 'Black Coffee', caloriesPer100g: 2, proteinPer100g: 0.3, carbsPer100g: 0, fatsPer100g: 0, category: 'Beverages', unit: 'ml'),
      FoodItem(id: 'juice_orange', name: 'Orange Juice', caloriesPer100g: 45, proteinPer100g: 0.7, carbsPer100g: 10, fatsPer100g: 0.2, category: 'Beverages', unit: 'ml'),
      
      // New Items
      FoodItem(id: 'pancakes', name: 'Pancakes (Plain)', caloriesPer100g: 227, proteinPer100g: 6.4, carbsPer100g: 28, fatsPer100g: 9.7, category: 'Grains'),
      FoodItem(id: 'pizza', name: 'Pizza (Margherita)', caloriesPer100g: 266, proteinPer100g: 11, carbsPer100g: 33, fatsPer100g: 10, category: 'Snacks'),
      FoodItem(id: 'burger', name: 'Veg Burger', caloriesPer100g: 250, proteinPer100g: 8, carbsPer100g: 30, fatsPer100g: 10, category: 'Snacks'),
      FoodItem(id: 'salad', name: 'Mixed Green Salad', caloriesPer100g: 17, proteinPer100g: 1.2, carbsPer100g: 3.3, fatsPer100g: 0.2, category: 'Vegetables'),
      FoodItem(id: 'soup_tomato', name: 'Tomato Soup', caloriesPer100g: 30, proteinPer100g: 1, carbsPer100g: 7, fatsPer100g: 0.5, category: 'Beverages', unit: 'ml'),
      FoodItem(id: 'watermelon', name: 'Watermelon', caloriesPer100g: 30, proteinPer100g: 0.6, carbsPer100g: 8, fatsPer100g: 0.2, category: 'Fruits'),
      FoodItem(id: 'almonds', name: 'Almonds', caloriesPer100g: 579, proteinPer100g: 21, carbsPer100g: 22, fatsPer100g: 49, category: 'Snacks'),
      FoodItem(id: 'milk_skim', name: 'Skim Milk', caloriesPer100g: 34, proteinPer100g: 3.4, carbsPer100g: 5, fatsPer100g: 0.1, category: 'Dairy', unit: 'ml'),
      FoodItem(id: 'mutton_curry', name: 'Mutton Curry', caloriesPer100g: 143, proteinPer100g: 16, carbsPer100g: 4, fatsPer100g: 7, category: 'Protein'),
    ];
  }

  static List<FoodItem> getAllFromBox(Box<FoodItem> box) {
    return box.values.toList();
  }

  static List<FoodItem> searchByName(Box<FoodItem> box, String query) {
    if (query.isEmpty) return getAllFromBox(box);
    final lower = query.toLowerCase();
    return box.values
        .where((f) => f.name.toLowerCase().contains(lower))
        .toList();
  }

  static List<FoodItem> filterByCategory(Box<FoodItem> box, String category) {
    if (category == 'All') return getAllFromBox(box);
    return box.values.where((f) => f.category == category).toList();
  }

  static List<String> get categories => [
        'All',
        'Grains',
        'Protein',
        'Dairy',
        'Vegetables',
        'Fruits',
        'Snacks',
        'Beverages',
        'Other',
      ];
}
