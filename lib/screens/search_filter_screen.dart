import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../models/meal_entry_model.dart';
import '../core/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/food_database_service.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark(context),
        title: const Text('Search & Filter'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textFaint(context),
          tabs: const [
            Tab(text: 'Food Items'),
            Tab(text: 'Meal History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FoodSearchTab(searchController: _searchController),
          _MealHistoryTab(),
        ],
      ),
    );
  }
}

// ─── Food Search Tab ──────────────────────────────────────────────────────────
class _FoodSearchTab extends ConsumerStatefulWidget {
  final TextEditingController searchController;

  const _FoodSearchTab({required this.searchController});

  @override
  ConsumerState<_FoodSearchTab> createState() => _FoodSearchTabState();
}

class _FoodSearchTabState extends ConsumerState<_FoodSearchTab> {
  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final filteredFoods = ref.watch(filteredFoodItemsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: widget.searchController,
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Search food items...',
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textFaint(context)),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: AppTheme.textFaint(context)),
                      onPressed: () {
                        widget.searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
            ),
          ),
        ),
        // Category chips
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: FoodDatabaseService.categories.map((cat) {
                final isSelected = cat == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) =>
                        ref.read(selectedCategoryProvider.notifier).state = cat,
                    selectedColor: AppTheme.primary.withOpacity(0.3),
                    checkmarkColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${filteredFoods.length} foods found',
                style: TextStyle(fontSize: 13, color: AppTheme.textFaint(context)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredFoods.isEmpty
              ? EmptyStateWidget(
                  emoji: '🔍',
                  title: 'No results',
                  subtitle: query.isNotEmpty
                      ? 'No foods match "$query"'
                      : 'No foods in this category',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filteredFoods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final food = filteredFoods[i];
                    return GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  food.name.isNotEmpty ? food.name.substring(0, 1).toUpperCase() : '🍽️',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        food.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textMain(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (food.isCustom)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Text(
                                          'Custom',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: AppTheme.accent,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  food.category,
                                  style: TextStyle(
                                      fontSize: 11, color: AppTheme.textFaint(context)),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _MacroChip('P', food.proteinPer100g, AppTheme.proteinColor),
                                    const SizedBox(width: 4),
                                    _MacroChip('C', food.carbsPer100g, AppTheme.carbsColor),
                                    const SizedBox(width: 4),
                                    _MacroChip('F', food.fatsPer100g, AppTheme.fatsColor),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${food.caloriesPer100g.toInt()}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.accent,
                                ),
                              ),
                              Text(
                                'per 100${food.unit}',
                                style: TextStyle(
                                    fontSize: 9, color: AppTheme.textFaint(context)),
                              ),
                            ],
                          ),
                          if (food.isCustom)
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: AppTheme.error, size: 18),
                              onPressed: () {
                                ref
                                    .read(foodItemsProvider.notifier)
                                    .deleteCustomFood(food.id);
                              },
                            ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
                  },
                ),
        ),
      ],
    );
  }

  String _getCategoryEmoji(String cat) {
    switch (cat) {
      case 'Grains': return '🌾';
      case 'Protein': return '🥩';
      case 'Dairy': return '🥛';
      case 'Vegetables': return '🥦';
      case 'Fruits': return '🍎';
      case 'Snacks': return '🍿';
      case 'Beverages': return '☕';
      default: return '🍽️';
    }
  }
}

// ─── Meal History Tab ─────────────────────────────────────────────────────────
class _MealHistoryTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MealHistoryTab> createState() => _MealHistoryTabState();
}

class _MealHistoryTabState extends ConsumerState<_MealHistoryTab> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _mealTypeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(mealEntriesProvider);
    final filtered = _applyFilters(allEntries.cast<MealEntry>());

    return Column(
      children: [
        // Filter Controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Date Range
              Row(
                children: [
                  Expanded(
                    child: _DatePickerButton(
                      label: _fromDate == null
                          ? 'From Date'
                          : DateFormat('MMM d').format(_fromDate!),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _fromDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
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
                        if (d != null) setState(() => _fromDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DatePickerButton(
                      label: _toDate == null
                          ? 'To Date'
                          : DateFormat('MMM d').format(_toDate!),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _toDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
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
                        if (d != null) setState(() => _toDate = d);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Meal Type Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks']
                      .map((type) {
                    final isSelected = _mealTypeFilter == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _mealTypeFilter = type),
                        selectedColor: AppTheme.primary.withOpacity(0.3),
                        checkmarkColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primary : AppTheme.textMuted(context),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} entries',
                style: TextStyle(fontSize: 13, color: AppTheme.textFaint(context)),
              ),
              if (_fromDate != null || _toDate != null || _mealTypeFilter != 'All')
                TextButton(
                  onPressed: () => setState(() {
                    _fromDate = null;
                    _toDate = null;
                    _mealTypeFilter = 'All';
                  }),
                  child: const Text('Clear Filters',
                      style: TextStyle(color: AppTheme.accentOrange, fontSize: 12)),
                ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyStateWidget(
                  emoji: '📋',
                  title: 'No entries found',
                  subtitle: 'Try adjusting your filters',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final entry = filtered[i];
                    return GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
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
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    MealTypeBadge(mealType: entry.mealType),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('MMM d, EEE').format(entry.date),
                                      style: TextStyle(
                                          fontSize: 11, color: AppTheme.textFaint(context)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${entry.quantity.toInt()}${entry.unit} · P:${entry.protein.toStringAsFixed(1)}g C:${entry.carbs.toStringAsFixed(1)}g F:${entry.fats.toStringAsFixed(1)}g',
                                  style: TextStyle(
                                      fontSize: 11, color: AppTheme.textFaint(context)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${entry.calories.toInt()} kcal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accent,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms);
                  },
                ),
        ),
      ],
    );
  }

  List<MealEntry> _applyFilters(List<MealEntry> entries) {
    var result = entries;
    if (_fromDate != null) {
      result = result
          .where((e) =>
              e.date.isAfter(_fromDate!.subtract(const Duration(days: 1))))
          .toList();
    }
    if (_toDate != null) {
      result = result
          .where(
              (e) => e.date.isBefore(_toDate!.add(const Duration(days: 1))))
          .toList();
    }
    if (_mealTypeFilter != 'All') {
      result = result.where((e) => e.mealType == _mealTypeFilter).toList();
    }
    return result;
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePickerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 15, color: AppTheme.textFaint(context)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}g',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
