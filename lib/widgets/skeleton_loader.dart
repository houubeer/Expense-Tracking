import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Shimmer effect for skeleton loading states
class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration period;

  const SkeletonLoader({
    super.key,
    required this.child,
    this.enabled = true,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                isDark
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surfaceContainerHigh,
                isDark
                    ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
                    : colorScheme.surfaceContainerHigh.withOpacity(0.5),
                isDark
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surfaceContainerHigh,
              ],
              transform: GradientTranslation(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class GradientTranslation extends GradientTransform {
  final double offset;

  const GradientTranslation(this.offset);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset, 0.0, 0.0);
  }
}

/// Skeleton box with shimmer effect
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Skeleton line with shimmer (for text placeholders)
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
    );
  }
}

/// Skeleton circle (for avatars/icons)
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton expense list item
class SkeletonExpenseItem extends StatelessWidget {
  const SkeletonExpenseItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            SkeletonCircle(size: 48),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 120, height: 16),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonLine(width: 80, height: 12),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SkeletonLine(width: 80, height: 16),
                SizedBox(height: AppSpacing.xs),
                SkeletonLine(width: 60, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton budget category item
class SkeletonBudgetItem extends StatelessWidget {
  const SkeletonBudgetItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonCircle(size: 40),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(width: 100, height: 16),
                      SizedBox(height: AppSpacing.xs),
                      SkeletonLine(width: 150, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 8),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(width: 80, height: 12),
                SkeletonLine(width: 60, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list with multiple items
class SkeletonList extends StatelessWidget {
  final Widget itemBuilder;
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const SkeletonList({
    super.key,
    required this.itemBuilder,
    this.itemCount = 5,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: ListView.builder(
        padding: padding,
        itemCount: itemCount,
        itemBuilder: (context, index) => itemBuilder,
      ),
    );
  }
}
