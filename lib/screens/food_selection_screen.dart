import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_providers.dart';
import '../models/food_item_model.dart';
import '../services/food_database_service.dart';
import '../core/app_theme.dart';
import '../widgets/shared_widgets.dart';

class FoodSelectionScreen extends ConsumerStatefulWidget {
  final String mealType;
  final DateTime date;

  const FoodSelectionScreen({
    super.key,
    required this.mealType,
    required this.date,
  });

  @override
  ConsumerState<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends ConsumerState<FoodSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  FoodItem? _selectedFood;
  final _quantityController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Set a different default category based on meal type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String defaultCat = 'All';
      if (widget.mealType == 'Breakfast') defaultCat = 'Fruits';
      if (widget.mealType == 'Lunch') defaultCat = 'Grains';
      if (widget.mealType == 'Dinner') defaultCat = 'Protein';
      if (widget.mealType == 'Snacks') defaultCat = 'Snacks';
      
      ref.read(selectedCategoryProvider.notifier).state = defaultCat;
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(selectedCategoryProvider);
    final filteredFoods = ref.watch(filteredFoodItemsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard(context),
        title: Text('Add to ${widget.mealType}'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textFaint(context),
          tabs: const [
            Tab(text: 'Food Database'),
            Tab(text: 'Custom Food'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodDatabase(filteredFoods, query, category),
          _buildCustomFoodForm(),
        ],
      ),
    );
  }

  Widget _buildFoodDatabase(List<FoodItem> foods, String query, String category) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Search food items...',
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textFaint(context)),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: AppTheme.textFaint(context)),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
            ),
          ),
        ),
        // Category Filter
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: FoodDatabaseService.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = FoodDatabaseService.categories[i];
              final isSelected = cat == category;
              return GestureDetector(
                onTap: () =>
                    ref.read(selectedCategoryProvider.notifier).state = cat,
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : AppTheme.bgCard(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppTheme.divider(context),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.textMain(context) : AppTheme.textMuted(context),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Food List
        Expanded(
          child: foods.isEmpty
              ? const EmptyStateWidget(
                  emoji: '🔍',
                  title: 'No foods found',
                  subtitle: 'Try a different search or add a custom food',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: foods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _FoodListTile(
                    food: foods[i],
                    isSelected: _selectedFood?.id == foods[i].id,
                    onTap: () {
                      setState(() => _selectedFood = foods[i]);
                      _showAddBottomSheet(context, foods[i]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddBottomSheet(BuildContext context, FoodItem food) {
    _quantityController.text = '100';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final qty = double.tryParse(_quantityController.text) ?? 100;
          final calories = food.getCalories(qty);
          final protein = food.getProtein(qty);
          final carbs = food.getCarbs(qty);
          final fats = food.getFats(qty);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  food.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain(context),
                  ),
                ),
                Text(
                  food.category,
                  style: TextStyle(fontSize: 13, color: AppTheme.textFaint(context)),
                ),
                const SizedBox(height: 16),
                // Nutrition preview
                Row(
                  children: [
                    _NutriBadge('${calories.toInt()}', 'kcal', AppTheme.calorieColor),
                    const SizedBox(width: 8),
                    _NutriBadge('${protein.toStringAsFixed(1)}g', 'Protein', AppTheme.proteinColor),
                    const SizedBox(width: 8),
                    _NutriBadge('${carbs.toStringAsFixed(1)}g', 'Carbs', AppTheme.carbsColor),
                    const SizedBox(width: 8),
                    _NutriBadge('${fats.toStringAsFixed(1)}g', 'Fats', AppTheme.fatsColor),
                  ],
                ),
                const SizedBox(height: 16),
                // Quantity
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Quantity (${food.unit})',
                          suffixText: food.unit,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addFoodEntry(ctx, food, qty),
                    child: Text('Add to ${widget.mealType}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _addFoodEntry(BuildContext ctx, FoodItem food, double qty) async {
    if (qty <= 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than 0')),
      );
      return;
    }

    await ref.read(mealEntriesProvider.notifier).addEntry(
          food: food,
          mealType: widget.mealType,
          quantity: qty,
          date: widget.date,
        );

    if (mounted) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food.name} added to ${widget.mealType}'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildCustomFoodForm() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    String selectedUnit = 'g';
    String selectedCategory = 'Other';

    return StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Custom Food',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Values are per 100g/ml/piece',
              style: TextStyle(fontSize: 13, color: AppTheme.textFaint(context)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Food Name *'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: calCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Calories (kcal) *'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    dropdownColor: AppTheme.bgCard(context),
                    items: ['g', 'ml', 'piece'].map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(u, style: TextStyle(color: AppTheme.textMain(context))),
                    )).toList(),
                    onChanged: (v) => setState(() => selectedUnit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: protCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Protein (g)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: carbCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Carbs (g)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: fatCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fats (g)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              dropdownColor: AppTheme.bgCard(context),
              items: FoodDatabaseService.categories
                  .where((c) => c != 'All')
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: TextStyle(color: AppTheme.textMain(context))),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v!),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add_rounded),
                label: const Text('Save Custom Food'),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final cal = double.tryParse(calCtrl.text);
                  if (name.isEmpty || cal == null || cal <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid name and calories'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                    return;
                  }
                  final food = FoodItem(
                    id: 'custom_${const Uuid().v4()}',
                    name: name,
                    caloriesPer100g: cal,
                    proteinPer100g: double.tryParse(protCtrl.text) ?? 0,
                    carbsPer100g: double.tryParse(carbCtrl.text) ?? 0,
                    fatsPer100g: double.tryParse(fatCtrl.text) ?? 0,
                    category: selectedCategory,
                    isCustom: true,
                    unit: selectedUnit,
                  );
                  await ref.read(foodItemsProvider.notifier).addCustomFood(food);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name added to database!'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                    _tabController.animateTo(0);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Food List Tile ───────────────────────────────────────────────────────────
class _FoodListTile extends StatelessWidget {
  final FoodItem food;
  final bool isSelected;
  final VoidCallback onTap;

  const _FoodListTile({
    required this.food,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.bgCard(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.divider(context),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getCategoryColor(food.category).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  food.name.isNotEmpty ? food.name.substring(0, 1).toUpperCase() : '🍽️',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(food.category),
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Custom',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'P:${food.proteinPer100g}g · C:${food.carbsPer100g}g · F:${food.fatsPer100g}g  per 100${food.unit}',
                    style: TextStyle(fontSize: 11, color: AppTheme.textFaint(context)),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                  ),
                ),
                Text(
                  'kcal',
                  style: TextStyle(fontSize: 10, color: AppTheme.textFaint(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Grains': return AppTheme.accentYellow;
      case 'Protein': return AppTheme.proteinColor;
      case 'Dairy': return Colors.blue;
      case 'Vegetables': return AppTheme.success;
      case 'Fruits': return AppTheme.accentOrange;
      case 'Snacks': return AppTheme.error;
      case 'Beverages': return AppTheme.info;
      default: return Colors.grey;
    }
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

// ─── Nutrition Badge ──────────────────────────────────────────────────────────
class _NutriBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _NutriBadge(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: AppTheme.textFaint(context)),
            ),
          ],
        ),
      ),
    );
  }
}
