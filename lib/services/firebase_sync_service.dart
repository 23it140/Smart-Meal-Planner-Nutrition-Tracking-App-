import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';

class FirebaseSyncService {
  static final _db = FirebaseFirestore.instance;

  /// Syncs all unsynced meals to Firestore
  static Future<void> syncMealsToCloud(String userId) async {
    try {
      final box = HiveService.mealBox;
      
      // Find meals that haven't been synced yet
      final unsyncedMeals = box.values.where((meal) => !meal.isSynced).toList();

      if (unsyncedMeals.isEmpty) {
        debugPrint('✅ No new meals to sync.');
        return;
      }

      int syncCount = 0;

      for (var meal in unsyncedMeals) {
        // Upload to Firestore
        await _db
            .collection('users')
            .doc(userId)
            .collection('meals')
            .doc(meal.id)
            .set({
          'foodId': meal.foodItemId,
          'foodName': meal.foodItemName,
          'mealType': meal.mealType,
          'quantity': meal.quantity,
          'calories': meal.calories,
          'protein': meal.protein,
          'carbs': meal.carbs,
          'fats': meal.fats,
          'date': meal.date.toIso8601String(),
          'syncedAt': FieldValue.serverTimestamp(),
        });

        // Mark as synced locally
        meal.isSynced = true;
        await meal.save();
        syncCount++;
      }

      debugPrint('☁️ Successfully synced $syncCount meals to Firebase!');
    } catch (e) {
      debugPrint('❌ Error syncing to Firebase: $e');
    }
  }
}
