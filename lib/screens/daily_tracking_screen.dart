import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../core/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'food_selection_screen.dart';

class DailyTrackingScreen extends ConsumerWidget {
  const DailyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final totals = ref.watch(dailyTotalsProvider);
    final goal = ref.watch(nutritionGoalProvider);
    final entries = ref.watch(dailyEntriesProvider);

    final calorieProgress = goal.targetCalories > 0
        ? (totals.calories / goal.targetCalories).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.bgDark(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bgDark(context),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Tracking'),
                Text(
                  DateFormat('EEEE, MMM d').format(date),
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted(context)),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.calendar_today_rounded),
                onPressed: () => _pickDate(context, ref, date),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  // Main Calorie Card
                  _buildCalorieCard(context, totals, goal, calorieProgress, entries.length),
                  const SizedBox(height: 16),
                  // Macro Cards Row
                  _buildMacroRow(totals, goal),
                  const SizedBox(height: 20),
                  // Meal Breakdown
                  SectionHeader(
                    title: 'Meal Breakdown',
                    action: TextButton.icon(
                      onPressed: () => _showAddMealSheet(context, ref, date),
                      icon: Icon(Icons.add_rounded, size: 16),
                      label: const Text('Quick Add'),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMealBreakdown(context, entries, date),
                  const SizedBox(height: 20),
                  // Calorie Progress
                  SectionHeader(title: 'Calorie Goal Progress'),
                  const SizedBox(height: 12),
                  _buildCalorieProgressSection(totals, goal),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieCard(BuildContext context, DailyNutrition totals,
      goal, double progress, int entryCount) {
    final remaining = (goal.targetCalories - totals.calories).clamp(0.0, double.infinity);
    final isOver = totals.calories > goal.targetCalories;

    return GlassCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A0E3D), Color(0xFF0D1A2E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Intake',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totals.calories.toInt().toString(),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMain(context),
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, left: 4),
                      child: Text(
                        'kcal',
                        style: TextStyle(fontSize: 16, color: AppTheme.textMuted(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isOver
                      ? '${(totals.calories - goal.targetCalories).toInt()} kcal over target'
                      : '${remaining.toInt()} kcal remaining',
                  style: TextStyle(
                    fontSize: 13,
                    color: isOver ? AppTheme.error : AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$entryCount items logged · Goal: ${goal.targetCalories.toInt()} kcal',
                  style: TextStyle(fontSize: 11, color: AppTheme.textFaint(context)),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.divider(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOver ? AppTheme.error : AppTheme.accent,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CalorieRing(consumed: totals.calories, target: goal.targetCalories, size: 120),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildMacroRow(DailyNutrition totals, goal) {
    return Row(
      children: [
        Expanded(
          child: GradientStatCard(
            label: 'Protein',
            value: totals.protein.toStringAsFixed(1),
            unit: 'g / ${goal.targetProtein.toInt()}g',
            gradient: const LinearGradient(
              colors: [Color(0xFF3D35CC), Color(0xFF5C6BC0)],
            ),
            icon: Icons.fitness_center_rounded,
            animationDelay: 100,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GradientStatCard(
            label: 'Carbs',
            value: totals.carbs.toStringAsFixed(1),
            unit: 'g / ${goal.targetCarbs.toInt()}g',
            gradient: AppTheme.warmGradient,
            icon: Icons.grain_rounded,
            animationDelay: 200,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GradientStatCard(
            label: 'Fats',
            value: totals.fats.toStringAsFixed(1),
            unit: 'g / ${goal.targetFats.toInt()}g',
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8F00), Color(0xFFFFCA28)],
            ),
            icon: Icons.water_drop_rounded,
            animationDelay: 300,
          ),
        ),
      ],
    );
  }

  Widget _buildMealBreakdown(BuildContext context, List entries, DateTime date) {
    const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
    final mealEmojis = {'Breakfast': '🌅', 'Lunch': '☀️', 'Dinner': '🌙', 'Snacks': '🍎'};

    return Column(
      children: mealTypes.map((type) {
        final mealEntries = entries.where((e) => e.mealType == type).toList();
        final totalCals = mealEntries.fold<double>(0, (s, e) => s + e.calories);

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(mealEmojis[type] ?? '🍽️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMain(context),
                      ),
                    ),
                    Text(
                      mealEntries.isEmpty
                          ? 'Not logged'
                          : '${mealEntries.length} items',
                      style: TextStyle(fontSize: 12, color: AppTheme.textFaint(context)),
                    ),
                  ],
                ),
              ),
              Text(
                mealEntries.isEmpty ? '—' : '${totalCals.toInt()} kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: mealEntries.isEmpty ? AppTheme.textFaint(context) : AppTheme.accent,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_rounded, size: 18),
                color: AppTheme.primary,
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodSelectionScreen(mealType: type, date: date),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalorieProgressSection(DailyNutrition totals, goal) {
    return GlassCard(
      child: Column(
        children: [
          MacroProgressBar(
            label: 'Calories',
            current: totals.calories,
            target: goal.targetCalories,
            color: AppTheme.calorieColor,
            unit: ' kcal',
          ),
          const SizedBox(height: 14),
          MacroProgressBar(
            label: 'Protein',
            current: totals.protein,
            target: goal.targetProtein,
            color: AppTheme.proteinColor,
          ),
          const SizedBox(height: 14),
          MacroProgressBar(
            label: 'Carbohydrates',
            current: totals.carbs,
            target: goal.targetCarbs,
            color: AppTheme.carbsColor,
          ),
          const SizedBox(height: 14),
          MacroProgressBar(
            label: 'Fats',
            current: totals.fats,
            target: goal.targetFats,
            color: AppTheme.fatsColor,
          ),
        ],
      ),
    );
  }

  void _pickDate(BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.bgCard(context),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }

  void _showAddMealSheet(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Meal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textMain(context)),
            ),
            const SizedBox(height: 16),
            ...['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map((type) => ListTile(
              leading: Text(
                {'Breakfast': '🌅', 'Lunch': '☀️', 'Dinner': '🌙', 'Snacks': '🍎'}[type]!,
                style: TextStyle(fontSize: 24),
              ),
              title: Text(type, style: TextStyle(color: AppTheme.textMain(context))),
              trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textFaint(context)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodSelectionScreen(mealType: type, date: date),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
