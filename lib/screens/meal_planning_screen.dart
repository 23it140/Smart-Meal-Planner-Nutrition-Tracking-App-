import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../core/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'food_selection_screen.dart';

class MealPlanningScreen extends ConsumerWidget {
  const MealPlanningScreen({super.key});

  static const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dailyEntries = ref.watch(dailyEntriesProvider);
    final goal = ref.watch(nutritionGoalProvider);
    final totals = ref.watch(dailyTotalsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, ref, selectedDate, totals, goal),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                ...mealTypes.map((type) => _MealTypeSection(
                      mealType: type,
                      entries: dailyEntries
                          .where((e) => e.mealType == type)
                          .toList(),
                      date: selectedDate,
                    )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref,
      DateTime date, DailyNutrition totals, goal) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.bgDark(context),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A0A3D), Color(0xFF0D0D1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meal Plan',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textMain(context),
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, MMM d').format(date),
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                      CalorieRing(
                        consumed: totals.calories,
                        target: goal.targetCalories,
                        size: 110,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DateSelector(ref: ref, selectedDate: date),
                ],
              ),
            ),
          ),
        ),
      ),
      title: Text(
        DateFormat('MMM d').format(date),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            final current = ref.read(themeModeProvider);
            ref.read(themeModeProvider.notifier).state = 
                current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ─── Date Selector ────────────────────────────────────────────────────────────
class _DateSelector extends StatelessWidget {
  final WidgetRef ref;
  final DateTime selectedDate;

  const _DateSelector({required this.ref, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = DateTime.now().subtract(Duration(days: 3 - i));
          final isSelected = day.day == selectedDate.day &&
              day.month == selectedDate.month &&
              day.year == selectedDate.year;
          final isToday = day.day == DateTime.now().day;

          return GestureDetector(
            onTap: () =>
                ref.read(selectedDateProvider.notifier).state = day,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.bgCard(context),
                borderRadius: BorderRadius.circular(14),
                border: isToday && !isSelected
                    ? Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).substring(0, 1),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? AppTheme.textMain(context) : AppTheme.textFaint(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppTheme.textMain(context) : AppTheme.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Meal Type Section ────────────────────────────────────────────────────────
class _MealTypeSection extends ConsumerWidget {
  final String mealType;
  final List entries;
  final DateTime date;

  const _MealTypeSection({
    required this.mealType,
    required this.entries,
    required this.date,
  });

  IconData get mealIcon {
    switch (mealType) {
      case 'Breakfast': return Icons.wb_sunny_rounded;
      case 'Lunch': return Icons.lunch_dining_rounded;
      case 'Dinner': return Icons.nightlight_round;
      case 'Snacks': return Icons.cookie_rounded;
      default: return Icons.restaurant_rounded;
    }
  }

  Color get mealColor {
    switch (mealType) {
      case 'Breakfast': return AppTheme.accentYellow;
      case 'Lunch': return AppTheme.accent;
      case 'Dinner': return AppTheme.primary;
      case 'Snacks': return AppTheme.accentOrange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCals = entries.fold<double>(0, (s, e) => s + e.calories);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mealColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(mealIcon, color: mealColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMain(context),
                        ),
                      ),
                      if (entries.isNotEmpty)
                        Text(
                          '${totalCals.toInt()} kcal · ${entries.length} items',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted(context),
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodSelectionScreen(
                        mealType: mealType,
                        date: date,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: mealColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
              ],
            ),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 10),
              Divider(color: AppTheme.divider(context), height: 1),
              const SizedBox(height: 8),
              ...entries.map((entry) => _MealEntryTile(entry: entry)),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tap + Add to log your $mealType',
                  style: TextStyle(fontSize: 12, color: AppTheme.textFaint(context)),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }
}

// ─── Meal Entry Tile ──────────────────────────────────────────────────────────
class _MealEntryTile extends ConsumerWidget {
  final dynamic entry;

  const _MealEntryTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.delete_rounded, color: AppTheme.error),
      ),
      onDismissed: (_) {
        ref.read(mealEntriesProvider.notifier).deleteEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${entry.foodItemName} removed'),
            action: SnackBarAction(label: 'Undo', onPressed: () {}),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  entry.foodItemName.isNotEmpty ? entry.foodItemName.substring(0, 1).toUpperCase() : '🍽️',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMain(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodItemName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMain(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${entry.quantity.toInt()}${entry.unit}  ·  P:${entry.protein.toStringAsFixed(1)}g  C:${entry.carbs.toStringAsFixed(1)}g  F:${entry.fats.toStringAsFixed(1)}g',
                    style: TextStyle(fontSize: 11, color: AppTheme.textFaint(context)),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.calories.toInt()} kcal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
