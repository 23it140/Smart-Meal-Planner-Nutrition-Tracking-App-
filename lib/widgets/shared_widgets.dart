import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.gradient,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient ??
              const LinearGradient(
                colors: [Color(0xFF1E1E35), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppTheme.divider(context), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Stat Card ───────────────────────────────────────────────────────
class GradientStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Gradient gradient;
  final IconData icon;
  final int animationDelay;

  const GradientStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.gradient,
    required this.icon,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textMuted(context), size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMain(context),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

// ─── Macro Progress Row ───────────────────────────────────────────────────────
class MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;
  final String unit;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted(context),
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(0)}$unit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMain(context),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ─── Meal Type Badge ──────────────────────────────────────────────────────────
class MealTypeBadge extends StatelessWidget {
  final String mealType;

  const MealTypeBadge({super.key, required this.mealType});

  @override
  Widget build(BuildContext context) {
    final data = _getMealData(mealType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: data.$2.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: data.$2.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(data.$1, style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            mealType,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: data.$2,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _getMealData(String type) {
    switch (type) {
      case 'Breakfast':
        return ('🌅', AppTheme.accentYellow);
      case 'Lunch':
        return ('☀️', AppTheme.accent);
      case 'Dinner':
        return ('🌙', AppTheme.primary);
      case 'Snacks':
        return ('🍎', AppTheme.accentOrange);
      default:
        return ('🍽️', Colors.grey);
    }
  }
}

// ─── Empty State Widget ───────────────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMain(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: AppTheme.textMuted(context)),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

// ─── Calorie Ring ─────────────────────────────────────────────────────────────
class CalorieRing extends StatelessWidget {
  final double consumed;
  final double target;
  final double size;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.target,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final remaining = (target - consumed).clamp(0.0, double.infinity);
    final isOver = consumed > target;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: AppTheme.divider(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? AppTheme.error : AppTheme.accent,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                consumed.toInt().toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMain(context),
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted(context)),
              ),
              Text(
                isOver
                    ? '+${(consumed - target).toInt()} over'
                    : '${remaining.toInt()} left',
                style: TextStyle(
                  fontSize: 11,
                  color: isOver ? AppTheme.error : AppTheme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
