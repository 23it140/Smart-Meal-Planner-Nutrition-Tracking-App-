import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../core/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyData = ref.watch(weeklyDataProvider);
    final goal = ref.watch(nutritionGoalProvider);
    final totals = ref.watch(dailyTotalsProvider);

    final weeklyAvg = weeklyData.isEmpty
        ? 0.0
        : weeklyData.fold<double>(0, (s, d) => s + d.calories) /
            weeklyData.length;
    final daysGoalMet =
        weeklyData.where((d) => d.calories >= goal.targetCalories * 0.9).length;
    final achievementPct = goal.targetCalories > 0
        ? ((totals.calories / goal.targetCalories) * 100).clamp(0.0, 100.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.bgDark(context),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bgDark(context),
            title: Text('Analytics'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Summary Stats
                _buildSummaryStats(weeklyAvg, daysGoalMet, achievementPct),
                const SizedBox(height: 20),

                // Weekly Calorie Bar Chart
                SectionHeader(title: '7-Day Calorie Trend'),
                const SizedBox(height: 12),
                _WeeklyBarChart(weeklyData: weeklyData, targetCalories: goal.targetCalories),
                const SizedBox(height: 20),

                // Macro Distribution Pie
                SectionHeader(title: 'Today\'s Macro Distribution'),
                const SizedBox(height: 12),
                _MacroPieChart(totals: totals),
                const SizedBox(height: 20),

                // Weekly Progress Table
                SectionHeader(title: 'Weekly Summary'),
                const SizedBox(height: 12),
                _WeeklySummaryTable(weeklyData: weeklyData, goal: goal),
                const SizedBox(height: 20),

                // Goal Achievement
                SectionHeader(title: 'Goal Achievement'),
                const SizedBox(height: 12),
                _GoalAchievementSection(
                  totals: totals,
                  goal: goal,
                  achievementPct: achievementPct,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(double weeklyAvg, int daysGoalMet, double achievementPct) {
    return Row(
      children: [
        Expanded(
          child: GradientStatCard(
            label: 'Weekly Avg',
            value: weeklyAvg.toInt().toString(),
            unit: 'kcal/day',
            gradient: AppTheme.primaryGradient,
            icon: Icons.trending_up_rounded,
            animationDelay: 0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GradientStatCard(
            label: 'Days on Track',
            value: '$daysGoalMet / 7',
            unit: 'this week',
            gradient: AppTheme.accentGradient,
            icon: Icons.check_circle_rounded,
            animationDelay: 100,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GradientStatCard(
            label: "Today's Goal",
            value: '${achievementPct.toInt()}%',
            unit: 'achieved',
            gradient: achievementPct >= 90
                ? AppTheme.accentGradient
                : achievementPct >= 50
                    ? AppTheme.warmGradient
                    : const LinearGradient(
                        colors: [Color(0xFF880000), Color(0xFFEF5350)],
                      ),
            icon: Icons.flag_rounded,
            animationDelay: 200,
          ),
        ),
      ],
    );
  }
}

// ─── Weekly Bar Chart ─────────────────────────────────────────────────────────
class _WeeklyBarChart extends StatelessWidget {
  final List<DailyNutrition> weeklyData;
  final double targetCalories;

  const _WeeklyBarChart({required this.weeklyData, required this.targetCalories});

  @override
  Widget build(BuildContext context) {
    final maxY = weeklyData.fold<double>(targetCalories,
            (m, d) => d.calories > m ? d.calories : m) *
        1.2;

    return GlassCard(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.bgCard(context)Light,
              getTooltipItem: (group, _, rod, __) {
                final day = weeklyData[group.x.toInt()];
                return BarTooltipItem(
                  '${DateFormat('EEE').format(day.date)}\n${rod.toY.toInt()} kcal',
                  TextStyle(
                    color: AppTheme.textMain(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  if (value.toInt() >= weeklyData.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('E').format(weeklyData[value.toInt()].date),
                      style: TextStyle(fontSize: 11, color: AppTheme.textFaint(context)),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppTheme.divider(context),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: targetCalories > 0
                ? [
                    HorizontalLine(
                      y: targetCalories,
                      color: AppTheme.accent.withOpacity(0.5),
                      strokeWidth: 2,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (_) => 'Goal',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        alignment: Alignment.topRight,
                      ),
                    ),
                  ]
                : [],
          ),
          barGroups: weeklyData.asMap().entries.map((entry) {
            final i = entry.key;
            final data = entry.value;
            final isToday = i == weeklyData.length - 1;
            final isOver = data.calories > targetCalories && targetCalories > 0;

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data.calories,
                  color: isToday
                      ? AppTheme.primary
                      : isOver
                          ? AppTheme.error
                          : AppTheme.accent.withOpacity(0.6),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// ─── Macro Pie Chart ──────────────────────────────────────────────────────────
class _MacroPieChart extends StatelessWidget {
  final DailyNutrition totals;

  const _MacroPieChart({required this.totals});

  @override
  Widget build(BuildContext context) {
    final proteinCal = totals.protein * 4;
    final carbsCal = totals.carbs * 4;
    final fatsCal = totals.fats * 9;
    final total = proteinCal + carbsCal + fatsCal;

    if (total <= 0) {
      return GlassCard(
        height: 180,
        child: const EmptyStateWidget(
          emoji: '📊',
          title: 'No data yet',
          subtitle: 'Log meals to see macro breakdown',
        ),
      );
    }

    return GlassCard(
      height: 200,
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 45,
                sections: [
                  PieChartSectionData(
                    value: proteinCal,
                    color: AppTheme.proteinColor,
                    title: '${((proteinCal / total) * 100).toInt()}%',
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain(context),
                    ),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: carbsCal,
                    color: AppTheme.carbsColor,
                    title: '${((carbsCal / total) * 100).toInt()}%',
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain(context),
                    ),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: fatsCal,
                    color: AppTheme.fatsColor,
                    title: '${((fatsCal / total) * 100).toInt()}%',
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMain(context),
                    ),
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem('Protein', '${totals.protein.toStringAsFixed(1)}g', AppTheme.proteinColor),
                const SizedBox(height: 12),
                _LegendItem('Carbs', '${totals.carbs.toStringAsFixed(1)}g', AppTheme.carbsColor),
                const SizedBox(height: 12),
                _LegendItem('Fats', '${totals.fats.toStringAsFixed(1)}g', AppTheme.fatsColor),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LegendItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textMuted(context))),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMain(context)),
        ),
      ],
    );
  }
}

// ─── Weekly Summary Table ─────────────────────────────────────────────────────
class _WeeklySummaryTable extends StatelessWidget {
  final List<DailyNutrition> weeklyData;
  final goal;

  const _WeeklySummaryTable({required this.weeklyData, required this.goal});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('Day', style: TextStyle(fontSize: 12, color: AppTheme.textMuted(context), fontWeight: FontWeight.w600))),
                Expanded(child: Text('Calories', style: TextStyle(fontSize: 12, color: AppTheme.textMuted(context), fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(child: Text('Protein', style: TextStyle(fontSize: 12, color: AppTheme.textMuted(context), fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(child: Text('Status', style: TextStyle(fontSize: 12, color: AppTheme.textMuted(context), fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
              ],
            ),
          ),
          Divider(color: AppTheme.divider(context), height: 1),
          ...weeklyData.map((day) {
            final isToday = day.date.day == DateTime.now().day;
            final onTrack = day.calories >= goal.targetCalories * 0.8 &&
                day.calories <= goal.targetCalories * 1.1;
            final hasData = day.calories > 0;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            if (isToday)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              DateFormat(isToday ? "'Today'" : 'EEE, d').format(day.date),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                color: isToday ? AppTheme.textMain(context) : AppTheme.textMuted(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          hasData ? '${day.calories.toInt()}' : '—',
                          style: TextStyle(fontSize: 13, color: AppTheme.textMuted(context)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          hasData ? '${day.protein.toStringAsFixed(1)}g' : '—',
                          style: TextStyle(fontSize: 13, color: AppTheme.textMuted(context)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: hasData
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: onTrack
                                      ? AppTheme.success.withOpacity(0.2)
                                      : AppTheme.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  onTrack ? '✓ Good' : '⚠️ Off',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: onTrack ? AppTheme.success : AppTheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const Text('—', textAlign: TextAlign.end,
                                style: TextStyle(color: AppTheme.textMain(context)24)),
                      ),
                    ],
                  ),
                ),
                if (weeklyData.last != day) Divider(color: AppTheme.divider(context), height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Goal Achievement Section ─────────────────────────────────────────────────
class _GoalAchievementSection extends StatelessWidget {
  final DailyNutrition totals;
  final goal;
  final double achievementPct;

  const _GoalAchievementSection({
    required this.totals,
    required this.goal,
    required this.achievementPct,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${achievementPct.toInt()}%',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: achievementPct >= 90
                      ? AppTheme.success
                      : achievementPct >= 60
                          ? AppTheme.warning
                          : AppTheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Goal', style: TextStyle(fontSize: 14, color: AppTheme.textMuted(context))),
                  Text(
                    _getStatus(achievementPct),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: achievementPct >= 90
                          ? AppTheme.success
                          : achievementPct >= 60
                              ? AppTheme.warning
                              : AppTheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: achievementPct / 100,
              minHeight: 14,
              backgroundColor: AppTheme.divider(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                achievementPct >= 90
                    ? AppTheme.success
                    : achievementPct >= 60
                        ? AppTheme.warning
                        : AppTheme.error,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getMessage(achievementPct),
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatus(double pct) {
    if (pct >= 100) return 'Achieved! 🎉';
    if (pct >= 90) return 'Almost There!';
    if (pct >= 60) return 'Good Progress';
    if (pct > 0) return 'Keep Going';
    return 'Not Started';
  }

  String _getMessage(double pct) {
    if (pct >= 100) return 'You\'ve hit your calorie goal today. Great work!';
    if (pct >= 90) return 'You\'re so close to your daily target!';
    if (pct >= 60) return 'More than halfway there. Keep logging!';
    if (pct > 0) return 'Log more meals to reach your daily goal.';
    return 'Start logging meals to track your progress.';
  }
}
