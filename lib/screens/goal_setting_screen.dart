import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';
import '../core/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';

class GoalSettingScreen extends ConsumerStatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  ConsumerState<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends ConsumerState<GoalSettingScreen> {
  late TextEditingController _caloriesCtrl;
  late TextEditingController _proteinCtrl;
  late TextEditingController _carbsCtrl;
  late TextEditingController _fatsCtrl;
  String _selectedProfile = 'Custom';
  bool _hasChanges = false;

  final _presets = {
    'Weight Loss': {'calories': 1500.0, 'protein': 90.0, 'carbs': 150.0, 'fats': 50.0},
    'Maintenance': {'calories': 2000.0, 'protein': 60.0, 'carbs': 250.0, 'fats': 65.0},
    'Muscle Gain': {'calories': 2500.0, 'protein': 150.0, 'carbs': 300.0, 'fats': 70.0},
    'Athlete': {'calories': 3000.0, 'protein': 180.0, 'carbs': 380.0, 'fats': 80.0},
    'Custom': null,
  };

  @override
  void initState() {
    super.initState();
    final goal = ref.read(nutritionGoalProvider);
    _caloriesCtrl = TextEditingController(text: goal.targetCalories.toInt().toString());
    _proteinCtrl = TextEditingController(text: goal.targetProtein.toInt().toString());
    _carbsCtrl = TextEditingController(text: goal.targetCarbs.toInt().toString());
    _fatsCtrl = TextEditingController(text: goal.targetFats.toInt().toString());
  }

  @override
  void dispose() {
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatsCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(String preset) {
    final data = _presets[preset];
    if (data != null) {
      setState(() {
        _selectedProfile = preset;
        _caloriesCtrl.text = data['calories']!.toInt().toString();
        _proteinCtrl.text = data['protein']!.toInt().toString();
        _carbsCtrl.text = data['carbs']!.toInt().toString();
        _fatsCtrl.text = data['fats']!.toInt().toString();
        _hasChanges = true;
      });
    } else {
      setState(() => _selectedProfile = preset);
    }
  }

  Future<void> _saveGoals() async {
    final calories = double.tryParse(_caloriesCtrl.text);
    final protein = double.tryParse(_proteinCtrl.text);
    final carbs = double.tryParse(_carbsCtrl.text);
    final fats = double.tryParse(_fatsCtrl.text);

    if (calories == null || calories <= 0) {
      _showError('Please enter a valid calorie target');
      return;
    }
    if (protein == null || protein < 0) {
      _showError('Please enter valid protein target');
      return;
    }

    await ref.read(nutritionGoalProvider.notifier).updateGoal(
          calories: calories,
          protein: protein,
          carbs: carbs ?? 250,
          fats: fats ?? 65,
        );

    if (mounted) {
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Goals updated successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(nutritionGoalProvider);
    final totals = ref.watch(dailyTotalsProvider);

    final calories = double.tryParse(_caloriesCtrl.text) ?? goal.targetCalories;
    final protein = double.tryParse(_proteinCtrl.text) ?? goal.targetProtein;
    final carbs = double.tryParse(_carbsCtrl.text) ?? goal.targetCarbs;
    final fats = double.tryParse(_fatsCtrl.text) ?? goal.targetFats;

    return Scaffold(
      backgroundColor: AppTheme.bgDark(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark(context),
        title: const Text('Nutrition Goals'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveGoals,
              child: const Text('Save', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700)),
            ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: AppTheme.error),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Profile Presets
            Text(
              'Quick Presets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textMain(context)),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presets.keys.map((preset) {
                  final isSelected = _selectedProfile == preset;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => _applyPreset(preset),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppTheme.primaryGradient : null,
                          color: isSelected ? null : AppTheme.bgCard(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : AppTheme.divider(context),
                          ),
                        ),
                        child: Text(
                          preset,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.textMain(context) : AppTheme.textMuted(context),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Goal Inputs
            Text(
              'Daily Targets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textMain(context)),
            ),
            const SizedBox(height: 12),
            _GoalInputCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppTheme.calorieColor,
              label: 'Daily Calorie Target',
              controller: _caloriesCtrl,
              unit: 'kcal',
              hint: 'e.g. 2000',
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 12),
            _GoalInputCard(
              icon: Icons.fitness_center_rounded,
              iconColor: AppTheme.proteinColor,
              label: 'Daily Protein Target',
              controller: _proteinCtrl,
              unit: 'g',
              hint: 'e.g. 50',
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 12),
            _GoalInputCard(
              icon: Icons.grain_rounded,
              iconColor: AppTheme.carbsColor,
              label: 'Daily Carbs Target',
              controller: _carbsCtrl,
              unit: 'g',
              hint: 'e.g. 250',
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 12),
            _GoalInputCard(
              icon: Icons.water_drop_rounded,
              iconColor: AppTheme.fatsColor,
              label: 'Daily Fats Target',
              controller: _fatsCtrl,
              unit: 'g',
              hint: 'e.g. 65',
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 24),

            // Macro Summary
            SectionHeader(title: 'Macro Breakdown Preview'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _MacroPreviewRow('Protein', protein * 4, (protein * 4) / (protein * 4 + carbs * 4 + fats * 9), AppTheme.proteinColor),
                  const SizedBox(height: 10),
                  _MacroPreviewRow('Carbs', carbs * 4, (carbs * 4) / (protein * 4 + carbs * 4 + fats * 9), AppTheme.carbsColor),
                  const SizedBox(height: 10),
                  _MacroPreviewRow('Fats', fats * 9, (fats * 9) / (protein * 4 + carbs * 4 + fats * 9), AppTheme.fatsColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Today's Progress vs Goal
            SectionHeader(title: "Today's Progress vs Goal"),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  MacroProgressBar(label: 'Calories', current: totals.calories, target: calories, color: AppTheme.calorieColor, unit: ' kcal'),
                  const SizedBox(height: 14),
                  MacroProgressBar(label: 'Protein', current: totals.protein, target: protein, color: AppTheme.proteinColor),
                  const SizedBox(height: 14),
                  MacroProgressBar(label: 'Carbs', current: totals.carbs, target: carbs, color: AppTheme.carbsColor),
                  const SizedBox(height: 14),
                  MacroProgressBar(label: 'Fats', current: totals.fats, target: fats, color: AppTheme.fatsColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save_rounded),
                label: const Text('Save Goals'),
                onPressed: _saveGoals,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalInputCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final TextEditingController controller;
  final String unit;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _GoalInputCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.controller,
    required this.unit,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textMuted(context))),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textMain(context)),
                  decoration: InputDecoration(
                    hintText: hint,
                    suffixText: unit,
                    suffixStyle: TextStyle(color: iconColor, fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    fillColor: Colors.transparent,
                    filled: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05);
  }
}

class _MacroPreviewRow extends StatelessWidget {
  final String label;
  final double calories;
  final double fraction;
  final Color color;

  const _MacroPreviewRow(this.label, this.calories, this.fraction, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = fraction.isNaN || fraction.isInfinite ? 0.0 : fraction;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textMuted(context))),
        const Spacer(),
        Text(
          '${calories.toInt()} kcal',
          style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Text(
          '(${(pct * 100).toInt()}%)',
          style: TextStyle(fontSize: 12, color: AppTheme.textFaint(context)),
        ),
      ],
    );
  }
}
